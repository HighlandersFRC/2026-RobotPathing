package frc.robot.commands;

import org.json.JSONObject;

import edu.wpi.first.wpilibj2.command.InstantCommand;

import frc.robot.subsystems.Drive;
import edu.wpi.first.math.geometry.Pose2d;
import edu.wpi.first.math.geometry.Rotation2d;
import org.littletonrobotics.junction.Logger;

public class SetOdometry extends InstantCommand {
    public SetOdometry(JSONObject args, Drive drive) {
        super(() -> {
            if (args == null) {
                Logger.recordOutput("Auto/OdoArgsNull", 1);
                return;
            }

            double x = args.optDouble("x", 0.0);
            double y = args.optDouble("y", 0.0);
            double angle = args.optDouble("angle", 0.0);

            try {
                drive.setOdometry(new Pose2d(x, y, Rotation2d.fromDegrees(angle)));
                Logger.recordOutput("Auto/OdoX", x);
                Logger.recordOutput("Auto/OdoY", y);
                Logger.recordOutput("Auto/OdoAngle", angle);
            } catch (Exception e) {
                Logger.recordOutput("Auto/OdoSetError", 1);
            }
        });
    }
}
