
% Example usage
input_value1 = 0;
input_value2 = 0;
input_value3 = 0;
input_value4 = 0;
input_value5 = 0;

mapped_values = map_servo_values(input_value1, input_value2, input_value3, input_value4, input_value5);
disp(['Mapped values for servo 1 to 5: ', num2str(mapped_values)]);

function mapped_values = map_servo_values(input_value1, input_value2, input_value3, input_value4, input_value5)
    % Define the input range for 5 servos
    input_min = [0, 0, -23, -34, -90];
    input_max = [180, 180, 157, 145, 90];

    % Define the new range for all 5 servos
    new_min = 2500;
    new_max = 500;

    % Map the input values to the new range for each servo
    mapped_value1 = map_value(input_value1, input_min(1), input_max(1), new_min, new_max);
    mapped_value2 = map_value(input_value2, input_min(2), input_max(2), new_min, new_max);
    mapped_value3 = map_value(input_value3, input_min(3), input_max(3), new_min, new_max);
    mapped_value4 = map_value(input_value4, input_min(4), input_max(4), new_min, new_max);
    mapped_value5 = map_value(input_value5, input_min(5), input_max(5), new_min, new_max);
    
    % Return the mapped values as an array
    mapped_values = [mapped_value1, mapped_value2, mapped_value3, mapped_value4, mapped_value5];
end

% Function to map a value from one range to another
function mapped_value = map_value(value, old_min, old_max, new_min, new_max)
    % Perform linear mapping
    mapped_value = (value - old_min) * (new_max - new_min) / (old_max - old_min) + new_min;
end