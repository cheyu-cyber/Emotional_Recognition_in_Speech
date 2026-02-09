function [q,q2, q4, forwardProbability, forwardProbability2, P1, P2] = hmm(cm, aest1, best1)
for analysis = 1:16
a = aest1{analysis};%[1/3, 1/3, 1/3;1/3,1/3,1/3;1/3,1/3,1/3];
b = best1{analysis};%[1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9;1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9;1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9,]; 
o = (round(cm(1:end,analysis)*2)+50).';%[1,6,9, 4, 7, 8, 2, 3, 5,3,7,1,9,2,4,3,7,4,9,7,5,6,3,2];
PIi = [1/3,1/3,1/3];
T = length(o);
N=length(a);

%alpha(forward)
alpha{analysis} = zeros(T,N);
for statei = 1:N
alpha{analysis}(1, statei) = PIi(statei)*b(statei, o(1));
end
normalizedAFactor{analysis}(1) = sum(alpha{analysis}(1,:));
alpha{analysis}(1,:) = alpha{analysis}(1,:)/normalizedAFactor{analysis}(1) ;
for time  = 1:T-1
    for statej = 1:N
        alpha{analysis}(time+1, statej) = b(statej, o(time+1))*(sum(alpha{analysis}(time,:)*a(:, statej)));
    end
    normalizedAFactor{analysis}(time+1) = sum(alpha{analysis}(time+1, :));
    alpha{analysis}(time+1, :) = alpha{analysis}(time+1, :)/normalizedAFactor{analysis}(time+1);
end

forwardProbability{analysis} = sum(alpha{analysis}(T,:))*normalizedAFactor{analysis}(T);


%beta{analysis}(backward)
beta{analysis} = zeros(T, N);
beta{analysis}(T, :)=1;
for time = T-1:-1:1
    for statei = 1:N
        beta{analysis}(time, statei) = sum(a(statei, :)*b(:, o(time+1))*beta{analysis}(time+1, :));%
    end
    normalizedBFactor{analysis}(time) = sum(beta{analysis}(time,:));
beta{analysis}(time, statei)=beta{analysis}(time, statei)/normalizedBFactor{analysis}(time);
end
%gamma
for time = 1:T
    for statei = 1:N
        gamma{analysis}(time, statei) = (alpha{analysis}(time, statei))*(beta{analysis}(time, statei))/(sum(alpha{analysis}(time, :).*beta{analysis}(time, :)));
    end
end
q1{analysis} = zeros(1, T);
for time = 1:T
    [val, q1{analysis}(time)] = max(gamma{analysis}(time, :));
end

%delta{analysis}(viterbi)
%delta{analysis}=zeros(T,N);
for statei = 1:N
delta{analysis}(1, statei) = log(PIi(statei))+log(b(statei, o(1)));
phai{analysis}(1, statei) = 0;
end

for time = 2:T
    for statej = 1:N
        for statei = 1:N
            da(statei) = delta{analysis}(time-1, statei)+log(a(statei, statej));
        end
        [maxval, argmax] = max(da);
        delta{analysis}(time, statej) = maxval+log(b(statej, o(time)));
        phai{analysis}(time, statej) = argmax;
    end
end
[P1{analysis}, q2{analysis}(T)] = max(delta{analysis}(T, :));
time = T-1;
while time>=1
    q2{analysis}(time) = phai{analysis}(time+1, q2{analysis}(time+1));
    time = time-1;
end

%parameter estimation
   eta{analysis} = zeros(T-1, N, N);
   for time = 1:T-1
       for statei = 1:N
           for statej = 1:N
               eta{analysis}(time, statei, statej) = alpha{analysis}(time, statei)*a(statei, statej)*b(statej, o(time+1))*beta{analysis}(time+1, statej)/sum(alpha{analysis}(time, :)*a(:, :)*b(:, o(time+1))*beta{analysis}(time+1, :));
           end
       end
   end
   for time = 1:T-1
       for statei = 1:N
           gamma2{analysis}(time, statei) = sum(eta{analysis}(time, statei, :));
       end
   end
   %hmmtrain
   for statei = 1:N
   PIi2{analysis}(statei) = gamma2{analysis}(1, statei);
   end
   
   for statei = 1:N
       for statej = 1:N
           a2{analysis}(statei, statej) = sum(eta{analysis}(:, statei, statej))/sum(gamma2{analysis}(:, statej));
       end
   end
   b2{analysis}=zeros(size(b));
   for statej = 1:N
       for vk = 1:length(b)
       for time = 1:T
           if o(time) ==vk
       b2{analysis}(statej, vk) = b2{analysis}(statej, vk)+gamma{analysis}(time, statej)/sum(gamma{analysis}(:, statej));
           else
           end
       end
       end
   end  

end
for analysis = 1:16
a = a2{analysis};%[[1/3, 1/3, 1/3;1/3,1/3,1/3;1/3,1/3,1/3]];
b = b2{analysis};
%b = best1{analysis}+b2{analysis};%[1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9;1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9;1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9,]; 
o = (round(cm(1:end,analysis)*2)+50).';%[1,6,9, 4, 7, 8, 2, 3, 5,3,7,1,9,2,4,3,7,4,9,7,5,6,3,2];
PIi = PIi2{analysis};
T = length(o);
N=length(a);

%alpha(forward)
alpha2{analysis} = zeros(T,N);
for statei = 1:N
alpha2{analysis}(1, statei) = PIi(statei)*b(statei, o(1));
end
normalizedAFactor2{analysis}(1) = sum(alpha2{analysis}(1,:));
alpha2{analysis}(1,:) = alpha2{analysis}(1,:)/normalizedAFactor2{analysis}(1) ;
for time  = 1:T-1
    for statej = 1:N
        alpha2{analysis}(time+1, statej) = b(statej, o(time+1))*(sum(alpha2{analysis}(time,:)*a(:, statej)));
    end
    normalizedAFactor2{analysis}(time+1) = sum(alpha2{analysis}(time+1, :));
    alpha2{analysis}(time+1, :) = alpha2{analysis}(time+1, :)/normalizedAFactor2{analysis}(time+1);
end

forwardProbability2{analysis} = sum(alpha2{analysis}(T,:))*normalizedAFactor2{analysis}(T);


%beta{analysis}(backward)
beta2{analysis} = zeros(T, N);
beta2{analysis}(T, :)=1;
for time = T-1:-1:1
    for statei = 1:N
        beta2{analysis}(time, statei) = sum(a(statei, :)*b(:, o(time+1))*beta2{analysis}(time+1, :));
    end
normalizedBFactor{analysis}(time) = sum(beta2{analysis}(time,:));
beta2{analysis}(time, statei)=beta2{analysis}(time, statei)/normalizedBFactor{analysis}(time);
end
%gamma
for time = 1:T
    for statei = 1:N
        gamma3{analysis}(time, statei) = (alpha2{analysis}(time, statei))*(beta2{analysis}(time, statei))/(sum(alpha2{analysis}(time, :).*beta2{analysis}(time, :)));
    end
end
q3{analysis} = zeros(1, T);
for time = 1:T
    [val2, q3{analysis}(time)] = max(gamma3{analysis}(time, :));
end

%delta{analysis}(viterbi)
%delta{analysis}=zeros(T,N);
for statei = 1:N
delta2{analysis}(1, statei) = log(PIi(statei))+log(b(statei, o(1)));
phai2{analysis}(1, statei) = 0;
end

for time = 2:T
    for statej = 1:N
        for statei = 1:N
            da2(statei) = delta2{analysis}(time-1, statei)+log(a(statei, statej));
        end
        [maxval, argmax] = max(da2);
        delta2{analysis}(time, statej) = maxval+log(b(statej, o(time)));
        phai2{analysis}(time, statej) = argmax;
    end
end
[P2{analysis}, q4{analysis}(T)] = max(delta2{analysis}(T, :));
time = T-1;
while time>=1
    q4{analysis}(time) = phai2{analysis}(time+1, q4{analysis}(time+1));
    time = time-1;
end

%parameter estimation
   eta2{analysis} = zeros(T-1, N, N);
   for time = 1:T-1
       for statei = 1:N
           for statej = 1:N
               eta2{analysis}(time, statei, statej) = alpha2{analysis}(time, statei)*a(statei, statej)*b(statej, o(time+1))*beta2{analysis}(time+1, statej)/sum(alpha2{analysis}(time, :)*a(:, :)*b(:, o(time+1))*beta2{analysis}(time+1, :));
           end
       end
   end
   for time = 1:T-1
       for statei = 1:N
           gamma4{analysis}(time, statei) = sum(eta2{analysis}(time, statei, :));
       end
   end
   %hmmtrain
   for statei = 1:N
   PIi3{analysis}(statei) = gamma4{analysis}(1, statei);
   end
   
   for statei = 1:N
       for statej = 1:N
           a3{analysis}(statei, statej) = sum(eta2{analysis}(:, statei, statej))/sum(gamma4{analysis}(:, statej));
       end
   end
   b3{analysis}=zeros(size(b));
   for statej = 1:N
       for vk = 1:length(b)
       for time = 1:T
           if o(time) ==vk
       b3{analysis}(statej, vk) = b3{analysis}(statej, vk)+gamma3{analysis}(time, statej)/sum(gamma3{analysis}(:, statej));
           else
               
           end
       end
       end
   end  

end
for analysis = 1:16
    if (forwardProbability{analysis}>=forwardProbability2{analysis})
        q{analysis} = q2{analysis};
    else
        q{analysis} = q4{analysis};
    end
end
end









