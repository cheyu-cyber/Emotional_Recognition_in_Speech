perfmalenn11=zeros(3,3);
    Y=malenn11_outputs;
    Z=zeros(1, length(Y));
for i=1:length(Y)
    Z(i)=find(Y(:,i)==max(Y(:,i)));
    
end
perfmalenn11(1,1)=length(find(Z==1));
perfmalenn11(1,2)=length(find(Z==2));
perfmalenn11(1,3)=length(find(Z==3));
    Y=malenn21_outputs;
    Z=zeros(1, length(Y));
for i=1:length(Y)
    Z(i)=find(Y(:,i)==max(Y(:,i)));
end
perfmalenn11(2,1)=length(find(Z==1));
perfmalenn11(2,2)=length(find(Z==2));
perfmalenn11(2,3)=length(find(Z==3));
    Y=malenn31_outputs;
    Z=zeros(1, length(Y));
for i=1:length(Y)
    Z(i)=find(Y(:,i)==max(Y(:,i)));
end
perfmalenn11(3,1)=length(find(Z==1));
perfmalenn11(3,2)=length(find(Z==2));
perfmalenn11(3,3)=length(find(Z==3));