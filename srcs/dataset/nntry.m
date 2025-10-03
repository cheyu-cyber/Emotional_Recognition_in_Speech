perffemalenn11=zeros(3,3);
    Y=femalenn11_outputs;
    Z=zeros(1, length(Y));
for i=1:length(Y)
    Z(i)=find(Y(:,i)==max(Y(:,i)));
    
end
perffemalenn11(1,1)=length(find(Z==1));
perffemalenn11(1,2)=length(find(Z==2));
perffemalenn11(1,3)=length(find(Z==3));
    Y=femalenn21_outputs;
    Z=zeros(1, length(Y));
for i=1:length(Y)
    Z(i)=find(Y(:,i)==max(Y(:,i)));
end
perffemalenn11(2,1)=length(find(Z==1));
perffemalenn11(2,2)=length(find(Z==2));
perffemalenn11(2,3)=length(find(Z==3));
    Y=femalenn31_outputs;
    Z=zeros(1, length(Y));
for i=1:length(Y)
    Z(i)=find(Y(:,i)==max(Y(:,i)));
end
perffemalenn11(3,1)=length(find(Z==1));
perffemalenn11(3,2)=length(find(Z==2));
perffemalenn11(3,3)=length(find(Z==3));