load("maleANN1network.mat");
net1 = network1;
net2 = load("femaleANN1network.mat");
net3 = load("maleANN2network.mat");
net4 = load("femaleANN2network.mat");
ou1=zeros(3,3);

for i = 1:13
    wavename = "maleSad_"+i+".wav";
    [CM, delCM, YM, delYM]=mfccfunc(wavename);
    output = sim(net1,CM.');
    ou = zeros(1,length(output));
    for j = 1:length(output)
        ou(j)=find(output(:,j)==max(output(:,j)));
    end
    ou1(1,1) = ou1(1,1)+length(find(ou==1));
    ou1(1,2) = ou1(1,2)+length(find(ou==2));
    ou1(1,3) = ou1(1,3)+length(find(ou==3));
end
for i=1:10
    wavename = "malePositive_"+i+".wav";
    [CM, delCM, YM, delYM]=mfccfunc(wavename);
    output = sim(net1,CM.');
    ou = zeros(1,length(output));
    for j = 1:length(output)
        ou(j)=find(output(:,j)==max(output(:,j)));
    end
    ou1(2,1) = ou1(2,1)+length(find(ou==1));
    ou1(2,2) = ou1(2,2)+length(find(ou==2));
    ou1(2,3) = ou1(2,3)+length(find(ou==3));
end
for i=1:32
    wavename = "maleAngry_"+i+".wav";
    [CM, delCM, YM, delYM]=mfccfunc(wavename);
    output = sim(net1,CM.');
    ou = zeros(1,length(output));
    for j = 1:length(output)
        ou(j)=find(output(:,j)==max(output(:,j)));
    end
    ou1(3,1) = ou1(3,1)+length(find(ou==1));
    ou1(3,2) = ou1(3,2)+length(find(ou==2));
    ou1(3,3) = ou1(3,3)+length(find(ou==3));
end
