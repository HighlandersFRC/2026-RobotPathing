package frc.robot.commands;

import edu.wpi.first.math.geometry.Pose2d;
import edu.wpi.first.math.geometry.Rotation2d;
import edu.wpi.first.wpilibj.Timer;
import edu.wpi.first.wpilibj2.command.Command;
import frc.robot.subsystems.Drive;
import frc.robot.tools.PathLoader;
import frc.robot.tools.PosePoint;
import frc.robot.tools.math.Vector;

import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;
import org.littletonrobotics.junction.Logger;

public class FollowPath extends Command {
  private final Drive drive;
  private final List<PosePoint> points = new ArrayList<>();
  private final Timer timer = new Timer();
  private int currentIndex = 0;
  private static final double POSITION_TOLERANCE = 0.02;
  private static final double ANGLE_TOLERANCE = 0.05;
  private static final double MAX_SPEED = 6.7; // meters/sec
  private static final double MAX_ANGULAR = 2.0; // rad/sec

  public FollowPath(JSONObject arguments, Drive driveSubsystem) {
    this.drive = driveSubsystem;
    if (arguments != null && arguments.has("points")) {
      JSONArray pointsArray = arguments.getJSONArray("points");
      for (int i = 0; i < pointsArray.length(); i++) {
        JSONObject p = pointsArray.getJSONObject(i);
        points.add(new PosePoint(
            p.getDouble("x"),
            p.getDouble("y"),
            p.getDouble("angle"),
            p.getDouble("time")));
      }
    }
  }

  @Override
  public void initialize() {
    currentIndex = 0;
    timer.reset();
    timer.start();
  }

  private double wrapAngle(double angle) {
    while (angle > Math.PI)
      angle -= 2 * Math.PI;
    while (angle < -Math.PI)
      angle += 2 * Math.PI;
    return angle;
  }

  @Override
  public void execute() {
    if (currentIndex >= points.size())
      return;

    PosePoint target = points.get(currentIndex);
    Pose2d pose = drive.getMT2Odometry();

    double dx = target.x - pose.getX();
    double dy = target.y - pose.getY();
    double distance = Math.hypot(dx, dy);
    double dtheta = wrapAngle(target.theta - pose.getRotation().getRadians());

    currentIndex = (int) (timer.getTimestamp() / 0.5);

    double vx = (distance > 0) ? (dx / distance) * Math.min(distance, MAX_SPEED) : 0;
    double vy = (distance > 0) ? (dy / distance) * Math.min(distance, MAX_SPEED) : 0;
    double omega = Math.signum(dtheta) * Math.min(Math.abs(dtheta), MAX_ANGULAR);

    double cos = Math.cos(-pose.getRotation().getRadians());
    double sin = Math.sin(-pose.getRotation().getRadians());
    double robotX = vx * cos - vy * sin;
    double robotY = vx * sin + vy * cos;

    drive.autoDrive(new Vector(robotX, -robotY), -omega);

    Logger.recordOutput("FollowPath/X", target.x);
    Logger.recordOutput("FollowPath/Y", target.y);
    Logger.recordOutput("FollowPath/Theta", target.theta);
  }

  @Override
  public void end(boolean interrupted) {
    timer.stop();
    drive.stop();
  }

  @Override
  public boolean isFinished() {
    return currentIndex >= points.size();
  }
}
