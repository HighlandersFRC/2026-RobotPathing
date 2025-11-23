package frc.robot.commands.conditionals;

import org.json.JSONObject;
import edu.wpi.first.wpilibj2.command.Command;

public class LeftPath implements Conditional {

    private double meow = 0;

    public LeftPath() {

    }

    @Override
    public boolean evaluate() {
        System.out.println("Evaluating LeftPath Conditional: " + (meow == 67));
        return meow == 67;
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
        if (args != null) {
            if (args.has("value")) {
                meow = args.getDouble("value");
            }
        }
    }
}
