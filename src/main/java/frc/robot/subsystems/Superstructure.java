// Copyright (c) FIRST and other WPILib contributors.
// Open Source Software; you can modify and/or share it under the terms of
// the WPILib BSD license file in the root directory of this project.

package frc.robot.subsystems;

import java.util.function.BooleanSupplier;
import java.util.function.IntFunction;

import javax.lang.model.util.ElementScanner14;

import org.littletonrobotics.junction.Logger;

import com.fasterxml.jackson.databind.ser.BeanSerializer;

import edu.wpi.first.math.geometry.Pose2d;
import edu.wpi.first.wpilibj.Timer;
import edu.wpi.first.wpilibj2.command.SubsystemBase;
import frc.robot.Constants;
import frc.robot.OI;
import frc.robot.Robot;
import frc.robot.commands.DriveTrainOverride;
import frc.robot.subsystems.Drive.DriveState;

public class Superstructure extends SubsystemBase {
    /** Creates a new Superstructure. */
    public enum SuperState {
        DEFAULT,
        IDLE
    }

    private SuperState wantedSuperState = SuperState.IDLE;
    private SuperState currentSuperState = SuperState.IDLE;
    private boolean pathCompleted = false;

    public boolean algaeMode = false;

    private boolean manipulatorHasCoral = false;
    private BooleanSupplier coralInManipulator = () -> manipulatorHasCoral;

    Drive drive;
    Peripherals peripherals;

    public enum CurrentMode {
        ALGAE,
        CORAL
    }

    public CurrentMode currentMode = CurrentMode.CORAL;

    public Superstructure(Drive driveSubsystem, Peripherals peripheralSubsystem) {
        drive = driveSubsystem;
        peripherals = peripheralSubsystem;

    }

    public BooleanSupplier hasCoralInManipulator() {
        return coralInManipulator;
    }

    public void setManipulatorHasCoral(boolean hasCoral) {
        coralInManipulator = () -> hasCoral;
    }

    public void setCurrentMode(CurrentMode mode) {
        currentMode = mode;
    }

    public void setWantedState(SuperState wantedState) {
        System.out.println("Wanted State: " + wantedState);
        this.wantedSuperState = wantedState;

    }

    public SuperState getCurrentSuperState() {
        return currentSuperState;
    }

    public boolean isPathCompleted() {
        return pathCompleted;
    }

    private double backUpTime = Timer.getFPGATimestamp();

    private void applyStates() {
        switch (currentSuperState) {
            case DEFAULT:
                drive.setWantedState(DriveState.DEFAULT);
                break;
        }
    }

    private SuperState handleStateTransitions() {
        switch (wantedSuperState) {
            case DEFAULT:
                currentSuperState = SuperState.DEFAULT;
                break;

            default:
                currentSuperState = SuperState.DEFAULT;
                break;
        }
        return currentSuperState;
    }

    @Override
    public void periodic() {
        Logger.recordOutput("SuperStructure State", currentSuperState);
        currentSuperState = handleStateTransitions();
        applyStates();
    }
}