package frc.robot.commands.conditionals;

import org.json.JSONObject;

import edu.wpi.first.wpilibj2.command.Command;

public interface Conditional {

    boolean evaluate();

    Command onTrue();

    Command onFalse();

    void setArguments(JSONObject args);

}
