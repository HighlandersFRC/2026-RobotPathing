package frc.robot.commands.conditionals;

import org.json.JSONObject;

import edu.wpi.first.wpilibj2.command.Command;

public class StartRightPath implements Conditional {

    @Override
    public boolean evaluate() {
        return false;
    }

    @Override
    public Command onTrue() {
        return null;
    }

    @Override
    public Command onFalse() {
        return null;
    }

    @Override
    public void setArguments(JSONObject args) {
    }

}
