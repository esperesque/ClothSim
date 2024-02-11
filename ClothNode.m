classdef ClothNode < handle
    %CLOTHNODE A single point on a simulated cloth.
    %   Detailed explanation goes brrr
    
    properties
        PosX
        PosY
        Mass
        NeighborCount = 0
        NeighborsX = []
        NeighborsY = []
        ConstantExternalForce = [0 0]
        TotalForce = [0 0]
        Velocity = [0 0]
    end
    
    methods
        function obj = ClothNode(inputX,inputY,inputMass)
            %CLOTHNODE Construct an instance of this class
            %   Detailed explanation goes here
            obj.PosX = inputX;
            obj.PosY = inputY;
            obj.Mass = inputMass;
        end
        function addNeighbor(obj,inputX,inputY)
            obj.NeighborCount = obj.NeighborCount + 1;
            obj.NeighborsX = [obj.NeighborsX inputX];
            obj.NeighborsY = [obj.NeighborsY inputY];
        end
        function perturb(obj)
            % Adds a random perturbation to the node, for debug purposes
            obj.PosX = obj.PosX + ((randi(100)/50)-1.0)*0.05;
            obj.PosY = obj.PosY + ((randi(100)/50)-1.0)*0.05;
        end
        function applyForce(obj, forceVec)
            obj.TotalForce = obj.TotalForce + forceVec;
        end
        function calculateVelocity(obj)
            obj.Velocity = (1/obj.Mass) * ([0 0] + obj.TotalForce + obj.ConstantExternalForce);
        end
        function calculatePosition(obj)
            obj.PosX = eulerm(obj.PosX, obj.Velocity(1), 0.1);
            obj.PosY = eulerm(obj.PosY, obj.Velocity(2), 0.1);
        end
        function setExtForce(obj, forceVec)
            obj.ConstantExternalForce = forceVec;
        end
    end
end

