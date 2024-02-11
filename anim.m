% Simulation parameters
SIZE_X = 10; % Horizontal size of cloth
SIZE_Y = 10; % Vertical size of cloth
NODE_MASS = 7;
SPRING_CONSTANT = 100;
WINDOW_MARGIN = 5; % Margin between edge nodes and plot window border
TIME = 100; % Duration of simulation in deciseconds

% External force applied for testing purposes
EXT_FORCE = 3; % Magnitude of force
FORCE_DIR = [1 0]; % Direction of force
DURATION = 5; % Duration of force in deciseconds

xlims = [0-WINDOW_MARGIN SIZE_X+WINDOW_MARGIN];
ylims = [0-WINDOW_MARGIN SIZE_Y+WINDOW_MARGIN];

% Create an object storing the nodes, mapped to x-y coords
nodeGrid = cell([SIZE_X SIZE_Y]);

% Create nodes
for x = 1:SIZE_X
    for y = 1:SIZE_Y
        n = ClothNode(x, y, NODE_MASS);
        if x > 1
            % Neighbor to the left
            n.addNeighbor(x-1,y)
        end
        if x < SIZE_X
            % Neighbor to the right
            n.addNeighbor(x+1,y)
        end
        if y > 1
            % Bottom neighbor
            n.addNeighbor(x,y-1)
        end
        if y < SIZE_Y
            % Top neighbor
            n.addNeighbor(x,y+1)
        end
        nodeGrid(x,y) = {n};
    end
end

for t = 1:TIME
    pause(0.1);
    
    % Set a small constant force on the top-right node
    if t < DURATION
        nodeGrid{SIZE_X, SIZE_Y}.setExtForce(FORCE_DIR*EXT_FORCE);
    else
        nodeGrid{SIZE_X, SIZE_Y}.setExtForce([0 0]);
    end

    % Update cloth positions here

    % TEST: Add a random perturbation each frame to test animation
%     for x = 1:SIZE_X
%         for y = 1:SIZE_Y
%             nodeGrid{x,y}.perturb()
%         end
%     end

    % Calculate forces on each node

    for x = 1:SIZE_X
        for y = 1:SIZE_Y
            n = nodeGrid{x,y};
            n.TotalForce = [0 0];
            for nb = 1:n.NeighborCount
                % Calculate spring forces on the node
                k = SPRING_CONSTANT;

                % Get the adjacent node from the nodeGrid
                adj = nodeGrid{n.NeighborsX(nb),n.NeighborsY(nb)};
                
                % Distance between nodes
                dvec = [adj.PosX adj.PosY] - [n.PosX n.PosY];
                d = sqrt(dvec(1)^2 + dvec(2)^2);
                norm = dvec / d; % normalised direction vector

                % Spring extension, assuming distance between nodes at rest
                % is 1
                ext = d - 1;

                n.applyForce(norm*(ext*k));
            end
            n.calculateVelocity();
            n.calculatePosition();
        end
    end

    % Update the meshgrid
    [X, Y] = updateMeshgrid(SIZE_X, SIZE_Y, nodeGrid);

    % Draw the plot

    plot(X, Y, '-ro');
    hold on
    plot(X', Y', '-ro');
    xlim(xlims);
    ylim(ylims);
    %drawArrow([0 3], [6 8], [-10 10], [-10 10], {'Color','b'})
    title("Time elapsed: " + t/10 + " seconds.");
    hold off
end

function [X, Y] = updateMeshgrid(sx, sy, ng)
    for x = 1:sx
        for y = 1:sy
            X(x,y) = ng{x,y}.PosX;
            Y(x,y) = ng{x,y}.PosY;
        end
    end
end

% Function for drawing arrows. May be useful for indicating
% external forces.
function [ h ] = drawArrow( x,y,xlimits,ylimits,props )

xlim(xlimits)
ylim(ylimits)

h = annotation('arrow');
set(h,'parent', gca, ...
    'position', [x(1),y(1),x(2)-x(1),y(2)-y(1)], ...
    'HeadLength', 10, 'HeadWidth', 10, 'HeadStyle', 'cback1', ...
    props{:} );

end
