
% please load data like the following methods:
 load('./group_L/data1/spike.mat');
 load('./group_L/data1/layer.mat');
 cell_categ = load('./group_L/data1/cell_categ_exc.txt');

% load('./group_R/data1/spike.mat');
% load('./group_R/data1/layer.mat');
% cell_categ = load('./group_R/data1/cell_categ_exc.txt');

%%
% spike is a structured array
% the following component hold maximum time steps.
% check it.
spike{end}(2)

% all components except the last two component hold time stamps 
% of individual neurons

% from
spike{1}
% to
spike{end-2}

% 
for kk = 1:length(spike)-2; 
    FR(kk)=1000*length(spike{kk})./spike{end}(2);
end

% this is the number of neurons
neuron_num = length(spike)-2

%% "cell_categ" provides cell label about excatatory(1) or inhibitory neurons(0).
cell_categ
% the number will correspond with "neuron_num".
length(cell_categ)

%% layers
layer1  = intersect(layer.cortex_lim, layer.L1);
layer23 = intersect(layer.cortex_lim, layer.L23);
layer4  = intersect(layer.cortex_lim, layer.L4);
layer5  = intersect(layer.cortex_lim, layer.L5);
layer6  = intersect(layer.cortex_lim, layer.L6);

[bb,order] = sort([layer1;layer23;layer4;layer5;layer6]);

% the number will also correspond with "neuron_num".
length(layer1) + length(layer23) + length(layer4) + length(layer5) + length(layer6)


layer_categ = zeros(length(cell_categ),1);
layer_categ(1:length(layer1))                 = 1;  %%%%%
layer_categ(length(layer1)+1:length(layer1)+length(layer23)) = 2; %%%%%
layer_categ(length(layer1)+length(layer23)+1:...
            length(layer1)+length(layer23)+length(layer4)) = 3; %%%%%
layer_categ(length(layer1)+length(layer23)+length(layer4)+1:...
            length(layer1)+length(layer23)+length(layer4)+length(layer5)) = 4; %%%%%
layer_categ(length(layer1)+length(layer23)+length(layer4)+length(layer5)+1:...
            length(layer1)+length(layer23)+length(layer4)+length(layer5)+length(layer6)) = 5; %%%%%
        
layer_categ = layer_categ(order);  
        
% this layer_categ will hold the layer category information.
% layer_categ = 1 --> layer1
% layer_categ = 2 --> layer23
% layer_categ = 3 --> layer4
% layer_categ = 4 --> layer5
% layer_categ = 5 --> layer6
        
%%
figure()
title('example1: excitatory neurons in layer23')
hist(log10(FR(((cell_categ==1).*(layer_categ==2))==1)),40)
median(FR(((cell_categ==1).*(layer_categ==2))==1))

 
figure()
title('example2: inhibitory neurons in layer5')
hist(log10(FR(((cell_categ==0).*(layer_categ==4))==1)),10)
median(FR(((cell_categ==0).*(layer_categ==4))==1))

%%
for mm = 0:1
    for kk = 1:5
      FR_med(mm+1,kk)=median(FR(((cell_categ==mm).*(layer_categ==kk))==1));
    end
end

 FR_med
