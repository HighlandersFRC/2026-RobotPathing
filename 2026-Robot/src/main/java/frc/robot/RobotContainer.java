package frc.robot;

import frc.robot.commands.AutoRunner;
import frc.robot.commands.ZeroPigeon;
import frc.robot.subsystems.Drive;
import frc.robot.subsystems.Peripherals;

import java.io.File;
import java.io.FileReader;
import java.util.HashMap;
import java.util.function.BooleanSupplier;
import java.util.function.Supplier;

import org.json.JSONObject;
import org.json.JSONTokener;

import edu.wpi.first.wpilibj.Filesystem;
import edu.wpi.first.wpilibj2.command.Command;

public class RobotContainer {

  public final Peripherals peripherals = new Peripherals();
  public final Drive drive = new Drive(peripherals);

  private JSONObject[] autoJSONs;

  public RobotContainer() {
  }

  private void loadAutoJSONs() {
    autoJSONs = new JSONObject[Constants.paths.size()];
    for (int i = 0; i < Constants.paths.size(); i++) {
      try {
        File file = new File(Filesystem.getDeployDirectory(), Constants.paths.get(i));
        FileReader reader = new FileReader(file);
        autoJSONs[i] = new JSONObject(new JSONTokener(reader));
      } catch (Exception e) {
        System.out.println("ERROR LOADING PATH " + Constants.paths.get(i) + ": " + e);
        autoJSONs[i] = null;
      }
    }
  }

  public Command getAutonomousCommand() {
    if (Constants.paths.isEmpty() || autoJSONs[0] == null)
      return null;
    return new AutoRunner(Constants.paths.get(0), drive, peripherals);
  }

}
