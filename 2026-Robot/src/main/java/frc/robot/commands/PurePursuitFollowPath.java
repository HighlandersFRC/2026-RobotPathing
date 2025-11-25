package frc.robot.commands;

import edu.wpi.first.math.geometry.Pose2d;
import edu.wpi.first.math.geometry.Rotation2d;
import edu.wpi.first.wpilibj2.command.Command;
import frc.robot.subsystems.Drive;
import frc.robot.tools.PathLoader;
import frc.robot.tools.math.Vector;
import org.json.JSONArray;
import org.json.JSONObject;
import org.littletonrobotics.junction.Logger;

import java.util.ArrayList;
import java.util.List;

public class PurePursuitFollowPath extends Command {
    private final Drive drive;
    private final JSONArray rawPoints;
    private final JSONArray pointsWithVels;
    private final List<PathLoader.PosePoint> points = new ArrayList<>();
    private int currentIndex = 0;
    private boolean odometrySet = false;

    private final double kP_x = 3.0;
    private final double kP_y = 3.0;
    private final double kP_theta = 2.7;

    private static final double POSITION_TOLERANCE = 0.02;
    private static final double ANGLE_TOLERANCE = 0.05;

    public PurePursuitFollowPath(JSONObject arguments, Drive driveSubsystem) {
        this.drive = driveSubsystem;
        if (arguments != null && arguments.has("points"))
            rawPoints = arguments.getJSONArray("points");
        else
            rawPoints = new JSONArray();

        pointsWithVels = buildPointsWithVelocities(rawPoints);

        for (int i = 0; i < rawPoints.length(); i++) {
            JSONObject p = rawPoints.getJSONObject(i);
            points.add(new PathLoader.PosePoint(
                    p.optDouble("x", 0.0),
                    p.optDouble("y", 0.0),
                    p.optDouble("angle", 0.0),
                    p.optDouble("time", 0.0)));
        }
    }

    private JSONArray buildPointsWithVelocities(JSONArray raw) {
        JSONArray out = new JSONArray();
        int n = raw.length();
        if (n == 0)
            return out;

        double[] xs = new double[n], ys = new double[n], th = new double[n], t = new double[n];
        for (int i = 0; i < n; i++) {
            JSONObject p = raw.getJSONObject(i);
            xs[i] = p.optDouble("x", 0.0);
            ys[i] = p.optDouble("y", 0.0);
            th[i] = p.optDouble("angle", 0.0);
            double tt = p.has("time") ? p.optDouble("time", Double.NaN) : Double.NaN;
            t[i] = Double.isNaN(tt) ? i : tt;
        }

        double[] vx = new double[n], vy = new double[n], vth = new double[n];
        if (n == 1) {
            vx[0] = vy[0] = vth[0] = 0.0;
        } else {
            for (int i = 0; i < n; i++) {
                if (i == 0) {
                    double dt = t[1] - t[0];
                    if (Math.abs(dt) < 1e-6)
                        dt = 0.02;
                    vx[0] = (xs[1] - xs[0]) / dt;
                    vy[0] = (ys[1] - ys[0]) / dt;
                    vth[0] = wrap(th[1] - th[0]) / dt;
                } else if (i == n - 1) {
                    double dt = t[n - 1] - t[n - 2];
                    if (Math.abs(dt) < 1e-6)
                        dt = 0.02;
                    vx[i] = (xs[i] - xs[i - 1]) / dt;
                    vy[i] = (ys[i] - ys[i - 1]) / dt;
                    vth[i] = wrap(th[i] - th[i - 1]) / dt;
                } else {
                    double dt = t[i + 1] - t[i - 1];
                    if (Math.abs(dt) < 1e-6)
                        dt = 0.02;
                    vx[i] = (xs[i + 1] - xs[i - 1]) / dt;
                    vy[i] = (ys[i + 1] - ys[i - 1]) / dt;
                    vth[i] = wrap(th[i + 1] - th[i - 1]) / dt;
                }
            }
        }

        for (int i = 0; i < n; i++) {
            int cnt = 0;
            double sx = 0, sy = 0, st = 0;
            for (int j = i - 1; j <= i + 1; j++) {
                if (j < 0 || j >= n)
                    continue;
                sx += vx[j];
                sy += vy[j];
                st += vth[j];
                cnt++;
            }
            double svx = sx / cnt, svy = sy / cnt, svt = st / cnt;
            JSONObject p = raw.getJSONObject(i);
            JSONObject c = new JSONObject();
            c.put("x", p.optDouble("x", 0.0));
            c.put("y", p.optDouble("y", 0.0));
            c.put("angle", p.optDouble("angle", 0.0));
            c.put("time", p.optDouble("time", i));
            c.put("x_velocity", svx);
            c.put("y_velocity", svy);
            c.put("angular_velocity", svt);
            out.put(c);
        }
        return out;
    }

    private double wrap(double a) {
        while (a > Math.PI)
            a -= 2 * Math.PI;
        while (a < -Math.PI)
            a += 2 * Math.PI;
        return a;
    }

    private boolean insideRadius(double ax, double ay, double atheta, double radius) {
        double norm = Math.sqrt(ax * ax + ay * ay + atheta * atheta);
        return norm <= radius;
    }

    @Override
    public void initialize() {
        currentIndex = 0;
        if (rawPoints.length() > 0 && !odometrySet) {
            JSONObject first = rawPoints.getJSONObject(0);
            drive.setOdometry(new Pose2d(first.optDouble("x", 0.0), first.optDouble("y", 0.0),
                    new Rotation2d(first.optDouble("angle", 0.0))));
            odometrySet = true;
        }
    }

    @Override
    public void execute() {
        if (pointsWithVels.length() == 0)
            return;

        Pose2d pose = drive.getMT2Odometry();
        double currentX = pose.getX();
        double currentY = pose.getY();
        double currentTheta = pose.getRotation().getRadians();

        JSONObject last = pointsWithVels.getJSONObject(pointsWithVels.length() - 1);
        double dxFinal = last.getDouble("x") - currentX;
        double dyFinal = last.getDouble("y") - currentY;
        double dthetaFinal = wrap(last.getDouble("angle") - currentTheta);
        if (Math.hypot(dxFinal, dyFinal) < POSITION_TOLERANCE && Math.abs(dthetaFinal) < ANGLE_TOLERANCE) {
            drive.stop();
            return; // skip all velocity calculations
        }

        JSONObject targetPoint = pointsWithVels.getJSONObject(pointsWithVels.length() - 1);
        int targetIndex = pointsWithVels.length() - 1;

        for (int i = currentIndex; i < pointsWithVels.length(); i++) {
            JSONObject point = pointsWithVels.getJSONObject(i);
            double targetX = point.getDouble("x");
            double targetY = point.getDouble("y");
            double targetTheta = point.getDouble("angle");
            double targetXvel = point.optDouble("x_velocity", 0.0);
            double targetYvel = point.optDouble("y_velocity", 0.0);
            double targetThetavel = point.optDouble("angular_velocity", 0.0);

            targetTheta = wrap(targetTheta - currentTheta) + currentTheta;
            double linearVelMag = Math.hypot(targetYvel, targetXvel);
            double targetVelMag = Math.hypot(linearVelMag, targetThetavel);
            double lookaheadRadius = 0.6 * targetVelMag + 0.2;
            double deltaX = currentX - targetX;
            double deltaY = currentY - targetY;
            double deltaTheta = currentTheta - targetTheta;

            if (!insideRadius(deltaX, deltaY, deltaTheta, lookaheadRadius)) {
                targetIndex = i;
                targetPoint = pointsWithVels.getJSONObject(i);
                break;
            }
        }

        double targetX = targetPoint.getDouble("x");
        double targetY = targetPoint.getDouble("y");
        double targetTheta = wrap(targetPoint.getDouble("angle") - currentTheta) + currentTheta;

        double errX = targetX - currentX;
        double errY = targetY - currentY;
        double errTheta = wrap(targetTheta - currentTheta);

        double xVelNoFF = errX * kP_x;
        double yVelNoFF = errY * kP_y;
        double thetaVelNoFF = -errTheta * kP_theta;

        double feedForwardX = 0;
        double feedForwardY = 0;
        double feedForwardTheta = 0;

        double finalX = xVelNoFF + feedForwardX;
        double finalY = yVelNoFF + feedForwardY;
        double finalTheta = (thetaVelNoFF + feedForwardTheta) * 1.25;

        double cos = Math.cos(-currentTheta);
        double sin = Math.sin(-currentTheta);
        double robotX = finalX * cos - finalY * sin;
        double robotY = finalX * sin + finalY * cos;

        drive.autoDrive(new Vector(robotX, -robotY), finalTheta);
        currentIndex = Math.max(currentIndex, Math.min(targetIndex, pointsWithVels.length() - 1));

        Logger.recordOutput("PurePursuit/targetIndex", targetIndex);
        Logger.recordOutput("PurePursuit/currentIndex", currentIndex);
        Logger.recordOutput("PurePursuit/targetPose", new Pose2d(targetX, targetY, new Rotation2d(targetTheta)));
        Logger.recordOutput("PurePursuit/vel_field", new double[] { finalX, finalY, finalTheta });
        Logger.recordOutput("PurePursuit/vel_robot", new double[] { robotX, robotY });
    }

    @Override
    public void end(boolean interrupted) {
        drive.stop();
    }

    @Override
    public boolean isFinished() {
        if (pointsWithVels.length() == 0)
            return true;
        Pose2d pose = drive.getMT2Odometry();
        JSONObject last = pointsWithVels.getJSONObject(pointsWithVels.length() - 1);
        double dx = last.getDouble("x") - pose.getX();
        double dy = last.getDouble("y") - pose.getY();
        double dtheta = wrap(last.getDouble("angle") - pose.getRotation().getRadians());
        return Math.hypot(dx, dy) < POSITION_TOLERANCE && Math.abs(dtheta) < ANGLE_TOLERANCE;
    }
}
