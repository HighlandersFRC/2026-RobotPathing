package frc.robot;

import org.littletonrobotics.junction.LoggedRobot;
import org.littletonrobotics.junction.Logger;
import org.littletonrobotics.junction.networktables.NT4Publisher;
import org.littletonrobotics.junction.wpilog.WPILOGWriter;
import org.littletonrobotics.junction.LogFileUtil;

import edu.wpi.first.wpilibj2.command.Command;
import edu.wpi.first.wpilibj2.command.CommandScheduler;
import frc.robot.commands.AutoRunner;
import frc.robot.subsystems.Drive;
import frc.robot.subsystems.Peripherals;
import frc.robot.subsystems.Drive.DriveState;

import java.io.IOException;

public class Robot extends LoggedRobot {

  private RobotContainer m_robotContainer;
  private Command m_autonomousCommand;
  private Drive drive;
  private Peripherals peripherals;

  @Override
  public void robotInit() {
    // Start AdvantageScope logging
    Logger.recordMetadata("Robot", "Robot");
    if (isReal()) {
      Logger.addDataReceiver(new NT4Publisher());
    } else {
      setUseTiming(false);
      String replayLog = LogFileUtil.findReplayLog();
      Logger.addDataReceiver(new WPILOGWriter(LogFileUtil.addPathSuffix(replayLog, "_sim")));

    }
    Logger.start();

    m_robotContainer = new RobotContainer();
    drive = m_robotContainer.drive;
    peripherals = m_robotContainer.peripherals;
    drive.init("blue"); // your team color or alliance color
  }

  @Override
  public void robotPeriodic() {
    CommandScheduler.getInstance().run();
  }

  @Override
  public void autonomousInit() {
    CommandScheduler.getInstance().schedule(new AutoRunner("sample_path", drive, peripherals));
  }

  @Override
  public void autonomousPeriodic() {
  }

  @Override
  public void teleopInit() {
    if (m_autonomousCommand != null) {
      m_autonomousCommand.cancel();
    }
  }

  @Override
  public void teleopPeriodic() {
    drive.setWantedState(DriveState.DEFAULT);
    if (OI.driverMenuButton.getAsBoolean()) {
      peripherals.zeroPigeon();
    }
  }

  @Override
  public void disabledInit() {
  }

  @Override
  public void disabledPeriodic() {
  }

  @Override
  public void testInit() {
    CommandScheduler.getInstance().cancelAll();
  }

  @Override
  public void testPeriodic() {
  }

  @Override
  public void simulationInit() {
  }

  @Override
  public void simulationPeriodic() {
  }
}
