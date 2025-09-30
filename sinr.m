close all;
clear all;
rng(5)

% radius of the big circle
L = 10;

% radius of the nodes
r = 1;

% iterations
M = 10;

% Max nodes
N = 100;

% max no of eaves droppers
E = 10;

matrix = [];





% SINR parameters
eta = 2;
d_ref = 0.1;
P = 100;
N_0 = 1;
gamma = 1;
threshold = 1;




for n=50:50
    for m=1:1
        % get n random nodes uniformly distributed in the circle
        nodes = containers.Map('KeyType', 'int64', 'ValueType', 'any');
        sets = {};
        for i=1:n
            new_node = createNode(L);
            key = length(nodes)+1;
            nodes(key) = new_node;
            sets(length(sets)+1) = {key};

            interferences = calculateInterferences(nodes, eta, d_ref, P, N_0, gamma)
            
            break_flag = false;
            % see if the new node is near any other node, if yes, then add it to the same set and remove it from the sets
            for j=1:length(sets) - 1
                set = sets{j};
                for k=1:length(set)
                    node = nodes(set(k));

                    % disp([key, k, set(k)])
                    if dist(node, new_node) <= 2*r && interferences(key, set(k)) >= threshold && interferences(set(k), key) >= threshold
                        sets{j} = union(sets{j}, key);
                        % remove new node from the sets
                        sets(length(sets)) = [];
                        break_flag = true;
                    break;
                    end
                    
                end
                if break_flag == true
                    break;
                end
            end
            disp('sets')
            disp(sets)
        end

        [are_nodes_percolating, perc_set] = notPercolating(sets, nodes, L, r);
        disp('outside')
        disp([are_nodes_percolating, perc_set])
        
        if are_nodes_percolating == 0    %if the network is percolating
            matrix(n, m) = 1;
            plotNodes(nodes, perc_set, L, r);

        else   % if the network is not percolating
            matrix(n, m) = 0;
        end
    
    end
end



function interferences = calculateInterferences(nodes, eta, d_ref, P, N_0, gamma)
    interferences = [];
    for i=1:length(nodes)
        % I = [];
        for j=1:length(nodes)
            if i == j
                interferences(i, j) = 0;
            else
                d = dist(nodes(i), nodes(j));
                num = P * min(1, (d/d_ref)^(-eta));
                den = 0;
                for k = 1:length(nodes)
                    if k ~= j || k ~= i
                        d_k = dist(nodes(j), nodes(k));
                        den = den + min(1, (d_k/d_ref)^(-eta));
                    end
                end
                interferences(i, j) = num/(N_0 + gamma*den);
            end
        end
    end
end


function plotNodes(nodes, percolating_set, L, r)
    keys = nodes.keys();
    figure;
    xlim([-L-5 L+5]);
    ylim([-L-5 L+5]);
    hold on;
    viscircles([0, 0],L, 'Color', 'r');
    viscircles([0, 0],r, 'Color', 'g');
    for i = 1:length(nodes)
        key = keys{i};
        node = nodes(key);
        if ismember(key, percolating_set{1})
            viscircles([node(1), node(2)],r, 'Color', 'k');
            scatter(node(1), node(2), 'k*');
        else
            viscircles([node(1), node(2)],r, 'Color', 'b');
            scatter(node(1), node(2), 'b*');
        end
        textscatter([node(1)+0.5],[node(2)+0.5], string(key))
%         legend(sprintf('N_%d', key),'Location','southwest')
    end
    hold off;
end








% create a random node
function new_node = createNode(L)
    radius = L*rand();
    angle = 2*pi*rand();
    x = radius*cos(angle);
    y = radius*sin(angle);
    new_node = [x, y, radius];
end

% find dist between two nodes
function dist = dist(node1, node2)
    dist = sqrt((node1(1) - node2(1))^2 + (node1(2) - node2(2))^2);
end



function [is_not_percolating, percolating_set] = notPercolating(sets, nodes, L, r)
    is_not_percolating = true;
    percolating_set = false;
    if isempty(sets) == 0
        for i=1:length(sets)
%             disp(['ou',sets{i}])
            if isSetPercolating(sets{i}, nodes, L, r) == true
                is_not_percolating = false;
                percolating_set = sets(i);
                break;
            end
        end
    end
end


function is_set_percolating = isSetPercolating(set, nodes, L, r)
%     disp(['set',set])
    is_set_percolating = false;
    min_radius = inf;
    max_radius = -inf;
    for i = 1:length(set)
        node = nodes(set(i));
        rad = node(3);
        if rad < min_radius
            min_radius = rad;
        end
        if rad > max_radius
            max_radius = rad;
        end
    end
    
    if min_radius < r && max_radius > L-r
        is_set_percolating = true;
    end
end


