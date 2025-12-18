package frc.robot.commands;

import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.function.Function;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;

import edu.wpi.first.wpilibj.Filesystem;
import edu.wpi.first.wpilibj2.command.Command;
import edu.wpi.first.wpilibj2.command.CommandScheduler;
import edu.wpi.first.wpilibj2.command.InstantCommand;
import edu.wpi.first.wpilibj2.command.ParallelCommandGroup;

import frc.robot.subsystems.Drive;
import frc.robot.subsystems.Peripherals;

import frc.robot.commands.conditionals.Conditional;
import org.littletonrobotics.junction.Logger;

import edu.wpi.first.math.geometry.Pose2d;
import edu.wpi.first.math.geometry.Rotation2d;

public class AutoRunner extends Command {
  private final Drive drive;
  private final Peripherals peripherals;
  private final String pathName;

  private JSONArray rootCommands = new JSONArray();
  private final HashMap<String, Function<Object, Conditional>> conditionalMap = new HashMap<>();

  private final List<Command> activeCommands = new ArrayList<>();
  private final List<StackEntry> stack = new ArrayList<>();
  private final Set<String> triggerFired = new HashSet<>();

  private boolean odometryInitialized = false;

  private static class StackEntry {
    JSONArray array;
    int index;
    final Conditional switchConditional;
    final JSONObject switchObject;

    StackEntry(JSONArray a, int i, Conditional c, JSONObject o) {
      array = a;
      index = i;
      switchConditional = c;
      switchObject = o;
    }
  }

  public AutoRunner(String pathName, Drive drive, Peripherals peripherals) {
    this.drive = drive;
    this.peripherals = peripherals;
    this.pathName = pathName;
    initConditionals();
    loadPathFile();
  }

  private void initConditionals() {
    conditionalMap.put("should_turn_left", args -> new frc.robot.commands.conditionals.LeftPath());
    conditionalMap.put("start_main_path", args -> new frc.robot.commands.conditionals.StartMainPath());
    conditionalMap.put("start_left_path", args -> new frc.robot.commands.conditionals.LeftPath());
    conditionalMap.put("start_right_path", args -> new frc.robot.commands.conditionals.StartRightPath());
  }

  private void loadPathFile() {
    try {
      FileReader r = new FileReader(new File(Filesystem.getDeployDirectory(), pathName + ".json"));
      JSONObject json = new JSONObject(new JSONTokener(r));
      rootCommands = json.getJSONArray("commands");
    } catch (Exception e) {
      rootCommands = new JSONArray();
    }
  }

  @Override
  public void initialize() {
    activeCommands.clear();
    stack.clear();
    triggerFired.clear();
    odometryInitialized = false;
    stack.add(new StackEntry(rootCommands, 0, null, null));
    scheduleNextIfIdle();
  }

  private Command buildSingleCommand(String name, JSONObject args) {
    if (args == null)
      args = new JSONObject();
    switch (name) {
      case "FollowPath":
        return new FollowPath(args, drive);
      case "PurePursuitFollowPath":
        return new PurePursuitFollowPath(args, drive);
      case "Zero":
        return new ZeroPigeon(peripherals);
      case "Log":
        return new InstantCommand();
      default:
        return new InstantCommand();
    }
  }

  private void tryInitializeOdometry(JSONObject args) {
    if (odometryInitialized)
      return;
    if (args == null)
      return;
    JSONArray pts = args.optJSONArray("points");
    if (pts == null || pts.length() == 0)
      return;
    JSONObject p = pts.getJSONObject(0);
    double x = p.optDouble("x", 0);
    double y = p.optDouble("y", 0);
    double angle = p.optDouble("angle", 0);
    drive.setOdometry(new Pose2d(x, y, Rotation2d.fromDegrees(angle)));
    Logger.recordOutput("AutoRunner/OdometryInitX", x);
    Logger.recordOutput("AutoRunner/OdometryInitY", y);
    Logger.recordOutput("AutoRunner/OdometryInitAngle", angle);
    odometryInitialized = true;
  }

  private Command buildCommandBlock(JSONObject block) {
    JSONArray names = block.optJSONArray("commands");
    JSONObject args = block.optJSONObject("arguments");
    if (names == null || names.length() == 0)
      return null;
    List<Command> list = new ArrayList<>();
    for (int i = 0; i < names.length(); i++) {
      String n = names.getString(i);
      if (n.equals("FollowPath") || n.equals("PurePursuitFollowPath"))
        tryInitializeOdometry(args);
      Command c = buildSingleCommand(n, args);
      if (c != null)
        list.add(c);
    }
    if (list.isEmpty())
      return null;
    Command[] arr = list.toArray(new Command[0]);
    if (arr.length == 1)
      return arr[0];
    return new ParallelCommandGroup(arr);
  }

  private void scheduleCommandAndTrack(Command c) {
    if (c == null)
      return;
    CommandScheduler.getInstance().schedule(c);
    activeCommands.add(c);
  }

  private Conditional buildConditionalInstance(String condName, Object condArgs) {
    Function<Object, Conditional> factory = conditionalMap.get(condName);
    if (factory == null)
      return null;
    Conditional instance;
    try {
      instance = factory.apply(condArgs);
    } catch (Exception e) {
      instance = factory.apply(null);
    }
    if (instance != null && condArgs instanceof JSONObject) {
      try {
        instance.setArguments((JSONObject) condArgs);
      } catch (Exception ignored) {
      }
    }
    return instance;
  }

  private boolean triggerConditionTrueForNode(JSONObject node) {
    JSONObject trigger = node.optJSONObject("trigger");
    if (trigger == null)
      return true;
    if (!trigger.has("condition"))
      return true;
    String condName = trigger.optString("condition", "");
    if (condName.isEmpty())
      return true;
    Object condArgs = trigger.has("conditionArguments") ? trigger.get("conditionArguments") : null;
    Conditional c = buildConditionalInstance(condName, condArgs);
    if (c == null)
      return false;
    return c.evaluate();
  }

  private void runTriggerCommandsIfAny(JSONObject node, String pathId) {
    if (triggerFired.contains(pathId))
      return;
    JSONObject trigger = node.optJSONObject("trigger");
    if (trigger == null)
      return;
    JSONArray cmds = trigger.optJSONArray("commands");
    if (cmds == null)
      return;
    for (int i = 0; i < cmds.length(); i++) {
      String name = cmds.getString(i);
      Command c = buildSingleCommand(name, null);
      scheduleCommandAndTrack(c);
    }
    triggerFired.add(pathId);
  }

  private String currentPathId() {
    StringBuilder sb = new StringBuilder();
    for (StackEntry e : stack)
      sb.append("/").append(e.index);
    return sb.toString();
  }

  private void scheduleNextIfIdle() {
    if (!activeCommands.isEmpty())
      return;
    while (!stack.isEmpty()) {
      StackEntry top = stack.get(stack.size() - 1);
      if (top.index >= top.array.length()) {
        stack.remove(stack.size() - 1);
        continue;
      }
      JSONObject node = top.array.getJSONObject(top.index);
      String type = node.optString("type", "");
      String pathId = currentPathId();
      if (type.equals("CommandBlock")) {
        if (!triggerConditionTrueForNode(node))
          return;
        runTriggerCommandsIfAny(node, pathId);
        Command block = buildCommandBlock(node);
        if (block != null)
          scheduleCommandAndTrack(block);
        top.index++;
        return;
      }
      if (type.equals("Switch")) {
        String condName = node.optString("condition", "");
        if (condName.isEmpty()) {
          top.index++;
          continue;
        }
        Object condArgs = node.has("conditionArguments") ? node.get("conditionArguments") : null;
        Conditional condInstance = buildConditionalInstance(condName, condArgs);
        top.index++;
        if (condInstance == null)
          continue;
        boolean result = condInstance.evaluate();
        JSONArray branch = result ? node.optJSONArray("onTrue") : node.optJSONArray("onFalse");
        if (branch == null)
          continue;
        stack.add(new StackEntry(branch, 0, condInstance, node));
        return;
      }
      top.index++;
    }
  }

  private void handleActiveSwitchFlipIfNeeded() {
    if (stack.isEmpty())
      return;
    StackEntry top = stack.get(stack.size() - 1);
    if (top.switchConditional == null)
      return;
    boolean now = top.switchConditional.evaluate();
    JSONObject switchObj = top.switchObject;
    boolean currentlyTrue = top.array == switchObj.optJSONArray("onTrue");
    if (now != currentlyTrue) {
      for (Command c : new ArrayList<>(activeCommands))
        CommandScheduler.getInstance().cancel(c);
      activeCommands.clear();
      JSONArray newBranch = now ? switchObj.optJSONArray("onTrue") : switchObj.optJSONArray("onFalse");
      top.array = newBranch != null ? newBranch : new JSONArray();
      top.index = 0;
    }
  }

  private void cleanupFinishedActiveCommands() {
    Iterator<Command> it = activeCommands.iterator();
    while (it.hasNext()) {
      Command c = it.next();
      if (!CommandScheduler.getInstance().isScheduled(c))
        it.remove();
    }
  }

  @Override
  public void execute() {
    cleanupFinishedActiveCommands();
    if (!activeCommands.isEmpty()) {
      handleActiveSwitchFlipIfNeeded();
      return;
    }
    handleActiveSwitchFlipIfNeeded();
    scheduleNextIfIdle();
  }

  @Override
  public void end(boolean interrupted) {
    for (Command c : new ArrayList<>(activeCommands))
      CommandScheduler.getInstance().cancel(c);
    activeCommands.clear();
    stack.clear();
    triggerFired.clear();
    drive.stop();
  }

  @Override
  public boolean isFinished() {
    return stack.isEmpty() && activeCommands.isEmpty();
  }
}
