// Copyright (c) FIRST and other WPILib contributors.
// Open Source Software; you can modify and/or share it under the terms of
// the WPILib BSD license file in the root directory of this project.

package frc.robot.commands;

import java.util.ArrayList;
import java.util.List;
import java.util.function.BooleanSupplier;

import edu.wpi.first.wpilibj2.command.Command;
import edu.wpi.first.wpilibj2.command.CommandScheduler;

/** Add your docs here. */
public class Trigger {
    private BooleanSupplier condition;
    private List<Command> commands = new ArrayList<>();

    public Trigger(BooleanSupplier condition, Command... commands) {
        this.condition = condition;
        for (Command command : commands) {
            this.commands.add(command);
        }
    }

    private void runCommands() {
        for (Command command : commands) {
            CommandScheduler.getInstance().schedule(command);
        }
    }

    private void check() {
        if (condition.getAsBoolean()) {
            runCommands();
        }
    }
}
