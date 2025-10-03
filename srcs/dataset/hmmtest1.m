close, clc, clear all
for analysis = 1:13
    wavename = "maleSad_"+analysis+".wav";
    [CM, delCM, YM, delYM]=mfccfunc(wavename);
    %CM = round(CM);
    %delCM = round(delCM);
    %YM = round(YM);
    %delYM = round(delYM);
    if analysis==1
        input11 = CM;
        input12 = delCM;
        input13 = YM;
        input14 = delYM;
    else
        input11 = vertcat(input11, CM);
        input12 = vertcat(input12, delCM);
        input13 = vertcat(input13, YM);
        input14 = vertcat(input14, delYM);
    end
    output11(1:size(input11(1:end, 1))) = 1;
    output12(1:size(input12(1:end, 1))) = 1;
    test11{analysis} = CM;
    test12{analysis} = delCM;
    test13{analysis} = YM;
    test14{analysis} = delYM;
    outputnn11 = [1; 0; 0];
    for i=1:length(input11)-1
        outputnn11 = horzcat(outputnn11, [1;0;0]);
    end
    outputnn12 = [1; 0; 0];
    for i=1:length(input12)-1
        outputnn12 = horzcat(outputnn12, [1;0;0]);
    end
end

for analysis = 1:10
    wavename = "malePositive_"+analysis+".wav";
    [CM, delCM, YM, delYM]=mfccfunc(wavename);
    
    if analysis==1
        input21 = CM;
        input22 = delCM;
        input23 = YM;
        input24 = delYM;
    else
        input21 = vertcat(input21, CM);
        input22 = vertcat(input22, delCM);
        input23 = vertcat(input23, YM);
        input24 = vertcat(input24, delYM);
    end
    output21(1:size(input21(1:end, 1))) = 2;
    output22(1:size(input22(1:end, 1))) = 2;
    test21{analysis} = CM;
    test22{analysis} = delCM;
    test23{analysis} = YM;
    test24{analysis} = delYM;
    outputnn21 = [0; 1; 0];
    for i=1:length(input21)-1
        outputnn21 = horzcat(outputnn21, [0;1;0]);
    end
    outputnn22 = [0; 1; 0];
    for i=1:length(input22)-1
        outputnn22 = horzcat(outputnn22, [0;1;0]);
    end
end

for analysis = 1:32
    wavename = "maleAngry_"+analysis+".wav";
    [CM, delCM, YM, delYM]=mfccfunc(wavename);
    
    if analysis==1
        input31 = CM;
        input32 = delCM;
        input33 = YM;
        input34 = delYM;
    else
        input31 = vertcat(input31, CM);
        input32 = vertcat(input32, delCM);
        input33 = vertcat(input33, YM);
        input34 = vertcat(input34, delYM);
    end
    output31(1:size(input31(1:end, 1))) = 3;
    output32(1:size(input32(1:end, 1))) = 3;
    test31{analysis} = CM;
    test32{analysis} = delCM;
    test33{analysis} = YM;
    test34{analysis} = delYM;
    outputnn31 = [0; 0; 1];
    for i=1:length(input31)-1
        outputnn31 = horzcat(outputnn31, [0;0;1]);
    end
    outputnn32 = [0; 0; 1];
    for i=1:length(input32)-1
        outputnn32 = horzcat(outputnn32, [0;0;1]);
    end
   
end

inputnnmale1 = vertcat(input11, input21, input31).';
inputnnmale2 = vertcat(input12, input22, input32).';
inputnn3 = vertcat(input13, input23, input33).';
inputnn4 = vertcat(input14, input24, input34).';

bias = 50;
input11 = round(input11*2)+bias;input21 = round(input21*2)+bias;input31 = round(input31*2)+bias;
input12 = round(input12*2)+bias;input22 = round(input22*2)+bias;input32 = round(input32*2)+bias;
input13 = round(input13*2)+bias;input23 = round(input23*2)+bias;input33 = round(input33*2)+bias;
input14 = round(input14*2)+bias;input24 = round(input24*2)+bias;input34 = round(input34*2)+bias;
input1 = vertcat(input11, input21, input31);
input2 = vertcat(input12, input22, input32);
input3 = vertcat(input13, input23, input33);
input4 = vertcat(input14, input24, input34);
output1 = horzcat(output11, output21, output31);
output2 = horzcat(output12, output22, output32);
outputnnmale1 = horzcat(outputnn11, outputnn21, outputnn31);
outputnnmale2 = horzcat(outputnn12, outputnn22, outputnn32);
for i = 1:16
    [aest1{i}, best1{i}]= hmmestimate(input1(1:end, i), output1);
    [aest2{i}, best2{i}]= hmmestimate(input2(1:end, i), output2);
    [aest3{i}, best3{i}]= hmmestimate(input3(1:end, i), output1);
    [aest4{i}, best4{i}]= hmmestimate(input4(1:end, i), output2);   
    best2{i} = horzcat(best2{i}, zeros(3,20));
    ob{i} = (round(test11{4}(1:end,i)*2)+50).';
    [pstate{i}, pseq{i}, fs{i}, bs{i}, s{i}] = hmmdecode(ob{i}, aest1{i}, best1{i});
    [atrain1{i}, btrain1{i}]= hmmtrain(ob{i}, aest1{i}, best1{i});
end
perf1=zeros(3,3);
perf1mode=zeros(3,3);
perf1q2=zeros(3,3);
perf1q2mode=zeros(3,3);
perf1q4=zeros(3,3);
perf1q4mode=zeros(3,3);

for i = 1:13
[q11{i}, q2test11{i}, q4test11{i}, fP111{i}, fP211{i}, P111{i}, P211{i}] = hmm(test11{i}, aest1, best1);
for j = 1:16
    q111{i}(j) = mode(q11{i}{j}(:));    
    q2test111{i}(j) = mode(q2test11{i}{j}(:)); 
    q4test111{i}(j) = mode(q4test11{i}{j}(:)); 
    perf1(1,1)=perf1(1,1)+length(find(q11{i}{j}==1));
    perf1(1,2)=perf1(1,2)+length(find(q11{i}{j}==2));
    perf1(1,3)=perf1(1,3)+length(find(q11{i}{j}==3));
    perf1q2(1,1)=perf1q2(1,1)+length(find(q2test11{i}{j}==1));
    perf1q2(1,2)=perf1q2(1,2)+length(find(q2test11{i}{j}==2));
    perf1q2(1,3)=perf1q2(1,3)+length(find(q2test11{i}{j}==3));
    perf1q4(1,1)=perf1q4(1,1)+length(find(q4test11{i}{j}==1));
    perf1q4(1,2)=perf1q4(1,2)+length(find(q4test11{i}{j}==2));
    perf1q4(1,3)=perf1q4(1,3)+length(find(q4test11{i}{j}==3));
end
    perf1mode(1,1)=perf1mode(1,1)+length(find(q111{i}==1));
    perf1mode(1,2)=perf1mode(1,2)+length(find(q111{i}==2));
    perf1mode(1,3)=perf1mode(1,3)+length(find(q111{i}==3));
    perf1q2mode(1,1)=perf1q2mode(1,1)+length(find(q2test111{i}==1));
    perf1q2mode(1,2)=perf1q2mode(1,2)+length(find(q2test111{i}==2));
    perf1q2mode(1,3)=perf1q2mode(1,3)+length(find(q2test111{i}==3));
    perf1q4mode(1,1)=perf1q4mode(1,1)+length(find(q4test111{i}==1));
    perf1q4mode(1,2)=perf1q4mode(1,2)+length(find(q4test111{i}==2));
    perf1q4mode(1,3)=perf1q4mode(1,3)+length(find(q4test111{i}==3));
end

for i = 1:10
[q21{i}, q2test21{i}, q4test21{i},fP121{i}, fP221{i}, P121{i}, P221{i}] = hmm(test21{i}, aest1, best1);
for j = 1:16
    q211{i}(j) = mode(q21{i}{j}(:));
    q2test211{i}(j) = mode(q2test21{i}{j}(:)); 
    q4test211{i}(j) = mode(q4test21{i}{j}(:)); 
    perf1(2,1)=perf1(2,1)+length(find(q21{i}{j}==1));
    perf1(2,2)=perf1(2,2)+length(find(q21{i}{j}==2));
    perf1(2,3)=perf1(2,3)+length(find(q21{i}{j}==3));
    perf1q2(2,1)=perf1q2(2,1)+length(find(q2test21{i}{j}==1));
    perf1q2(2,2)=perf1q2(2,2)+length(find(q2test21{i}{j}==2));
    perf1q2(2,3)=perf1q2(2,3)+length(find(q2test21{i}{j}==3));
    perf1q4(2,1)=perf1q4(2,1)+length(find(q4test21{i}{j}==1));
    perf1q4(2,2)=perf1q4(2,2)+length(find(q4test21{i}{j}==2));
    perf1q4(2,3)=perf1q4(2,3)+length(find(q4test21{i}{j}==3));
end
    perf1mode(2,1)=perf1mode(2,1)+length(find(q211{i}==1));
    perf1mode(2,2)=perf1mode(2,2)+length(find(q211{i}==2));
    perf1mode(2,3)=perf1mode(2,3)+length(find(q211{i}==3));
    perf1q2mode(2,1)=perf1q2mode(2,1)+length(find(q2test211{i}==1));
    perf1q2mode(2,2)=perf1q2mode(2,2)+length(find(q2test211{i}==2));
    perf1q2mode(2,3)=perf1q2mode(2,3)+length(find(q2test211{i}==3));
    perf1q4mode(2,1)=perf1q4mode(2,1)+length(find(q4test211{i}==1));
    perf1q4mode(2,2)=perf1q4mode(2,2)+length(find(q4test211{i}==2));
    perf1q4mode(2,3)=perf1q4mode(2,3)+length(find(q4test211{i}==3));
end
for i = 1:32
[q31{i}, q2test31{i}, q4test31{i},fP131{i}, fP231{i}, P131{i}, P231{i}] = hmm(test31{i}, aest1, best1);
for j = 1:16
    q311{i}(j) = mode(q31{i}{j}(:));
    q2test311{i}(j) = mode(q2test31{i}{j}(:)); 
    q4test311{i}(j) = mode(q4test31{i}{j}(:)); 
    perf1(3,1)=perf1(3,1)+length(find(q31{i}{j}==1));
    perf1(3,2)=perf1(3,2)+length(find(q31{i}{j}==2));
    perf1(3,3)=perf1(3,3)+length(find(q31{i}{j}==3));
    perf1q2(3,1)=perf1q2(3,1)+length(find(q2test31{i}{j}==1));
    perf1q2(3,2)=perf1q2(3,2)+length(find(q2test31{i}{j}==2));
    perf1q2(3,3)=perf1q2(3,3)+length(find(q2test31{i}{j}==3));
    perf1q4(3,1)=perf1q4(3,1)+length(find(q4test31{i}{j}==1));
    perf1q4(3,2)=perf1q4(3,2)+length(find(q4test31{i}{j}==2));
    perf1q4(3,3)=perf1q4(3,3)+length(find(q4test31{i}{j}==3));
end
    perf1mode(3,1)=perf1mode(3,1)+length(find(q311{i}==1));
    perf1mode(3,2)=perf1mode(3,2)+length(find(q311{i}==2));
    perf1mode(3,3)=perf1mode(3,3)+length(find(q311{i}==3));
    perf1q2mode(3,1)=perf1q2mode(3,1)+length(find(q2test311{i}==1));
    perf1q2mode(3,2)=perf1q2mode(3,2)+length(find(q2test311{i}==2));
    perf1q2mode(3,3)=perf1q2mode(3,3)+length(find(q2test311{i}==3));
    perf1q4mode(3,1)=perf1q4mode(3,1)+length(find(q4test311{i}==1));
    perf1q4mode(3,2)=perf1q4mode(3,2)+length(find(q4test311{i}==2));
    perf1q4mode(3,3)=perf1q4mode(3,3)+length(find(q4test311{i}==3));
end


perf2=zeros(3,3);
perf2mode=zeros(3,3);
perf2q2=zeros(3,3);
perf2q2mode=zeros(3,3);
perf2q4=zeros(3,3);
perf2q4mode=zeros(3,3);

for i = 1:13
[q12{i}, q2test12{i}, q4test12{i},fP112{i}, fP212{i}, P112{i}, P212{i}] = hmm(test12{i}, aest2, best2);
for j = 1:16
    q121{i}(j) = mode(q12{i}{j}(:));
    q2test121{i}(j) = mode(q2test12{i}{j}(:)); 
    q4test121{i}(j) = mode(q4test12{i}{j}(:)); 
    perf2(1,1)=perf2(1,1)+length(find(q12{i}{j}==1));
    perf2(1,2)=perf2(1,2)+length(find(q12{i}{j}==2));
    perf2(1,3)=perf2(1,3)+length(find(q12{i}{j}==3));
    perf2q2(1,1)=perf2q2(1,1)+length(find(q2test12{i}{j}==1));
    perf2q2(1,2)=perf2q2(1,2)+length(find(q2test12{i}{j}==2));
    perf2q2(1,3)=perf2q2(1,3)+length(find(q2test12{i}{j}==3));
    perf2q4(1,1)=perf2q4(1,1)+length(find(q4test12{i}{j}==1));
    perf2q4(1,2)=perf2q4(1,2)+length(find(q4test12{i}{j}==2));
    perf2q4(1,3)=perf2q4(1,3)+length(find(q4test12{i}{j}==3));
end
    perf2mode(1,1)=perf2mode(1,1)+length(find(q121{i}==1));
    perf2mode(1,2)=perf2mode(1,2)+length(find(q121{i}==2));
    perf2mode(1,3)=perf2mode(1,3)+length(find(q121{i}==3));
    perf2q2mode(1,1)=perf2q2mode(1,1)+length(find(q2test121{i}==1));
    perf2q2mode(1,2)=perf2q2mode(1,2)+length(find(q2test121{i}==2));
    perf2q2mode(1,3)=perf2q2mode(1,3)+length(find(q2test121{i}==3));
    perf2q4mode(1,1)=perf2q4mode(1,1)+length(find(q4test121{i}==1));
    perf2q4mode(1,2)=perf2q4mode(1,2)+length(find(q4test121{i}==2));
    perf2q4mode(1,3)=perf2q4mode(1,3)+length(find(q4test121{i}==3));
    
end
for i = 1:10
[q22{i}, q2test22{i}, q4test22{i}, fP122{i}, fP222{i}, P122{i}, P222{i}] = hmm(test22{i}, aest2, best2);
for j = 1:16
    q221{i}(j) = mode(q22{i}{j}(:));
    q2test221{i}(j) = mode(q2test22{i}{j}(:)); 
    q4test221{i}(j) = mode(q4test22{i}{j}(:)); 
    perf2(2,1)=perf2(2,1)+length(find(q22{i}{j}==1));
    perf2(2,2)=perf2(2,2)+length(find(q22{i}{j}==2));
    perf2(2,3)=perf2(2,3)+length(find(q22{i}{j}==3));
    perf2q2(2,1)=perf2q2(2,1)+length(find(q2test22{i}{j}==1));
    perf2q2(2,2)=perf2q2(2,2)+length(find(q2test22{i}{j}==2));
    perf2q2(2,3)=perf2q2(2,3)+length(find(q2test22{i}{j}==3));
    perf2q4(2,1)=perf2q4(2,1)+length(find(q4test22{i}{j}==1));
    perf2q4(2,2)=perf2q4(2,2)+length(find(q4test22{i}{j}==2));
    perf2q4(2,3)=perf2q4(2,3)+length(find(q4test22{i}{j}==3));
end
    perf2mode(2,1)=perf2mode(2,1)+length(find(q221{i}==1));
    perf2mode(2,2)=perf2mode(2,2)+length(find(q221{i}==2));
    perf2mode(2,3)=perf2mode(2,3)+length(find(q221{i}==3));
    perf2q2mode(2,1)=perf2q2mode(2,1)+length(find(q2test221{i}==1));
    perf2q2mode(2,2)=perf2q2mode(2,2)+length(find(q2test221{i}==2));
    perf2q2mode(2,3)=perf2q2mode(2,3)+length(find(q2test221{i}==3));
    perf2q4mode(2,1)=perf2q4mode(2,1)+length(find(q4test221{i}==1));
    perf2q4mode(2,2)=perf2q4mode(2,2)+length(find(q4test221{i}==2));
    perf2q4mode(2,3)=perf2q4mode(2,3)+length(find(q4test221{i}==3));
    
end
for i = 1:32
[q32{i}, q2test32{i}, q4test32{i}, fP132{i}, fP232{i}, P132{i}, P232{i}] = hmm(test32{i}, aest2, best2);
for j = 1:16
    q321{i}(j) = mode(q32{i}{j}(:));
    q2test321{i}(j) = mode(q2test32{i}{j}(:)); 
    q4test321{i}(j) = mode(q4test32{i}{j}(:)); 
    perf2(3,1)=perf2(3,1)+length(find(q32{i}{j}==1));
    perf2(3,2)=perf2(3,2)+length(find(q32{i}{j}==2));
    perf2(3,3)=perf2(3,3)+length(find(q32{i}{j}==3));
    perf2q2(3,1)=perf2q2(3,1)+length(find(q2test32{i}{j}==1));
    perf2q2(3,2)=perf2q2(3,2)+length(find(q2test32{i}{j}==2));
    perf2q2(3,3)=perf2q2(3,3)+length(find(q2test32{i}{j}==3));
    perf2q4(3,1)=perf2q4(3,1)+length(find(q4test32{i}{j}==1));
    perf2q4(3,2)=perf2q4(3,2)+length(find(q4test32{i}{j}==2));
    perf2q4(3,3)=perf2q4(3,3)+length(find(q4test32{i}{j}==3));
end
    perf2mode(3,1)=perf2mode(3,1)+length(find(q321{i}==1));
    perf2mode(3,2)=perf2mode(3,2)+length(find(q321{i}==2));
    perf2mode(3,3)=perf2mode(3,3)+length(find(q321{i}==3));
    perf2q2mode(3,1)=perf2q2mode(3,1)+length(find(q2test321{i}==1));
    perf2q2mode(3,2)=perf2q2mode(3,2)+length(find(q2test321{i}==2));
    perf2q2mode(3,3)=perf2q2mode(3,3)+length(find(q2test321{i}==3));
    perf2q4mode(3,1)=perf2q4mode(3,1)+length(find(q4test321{i}==1));
    perf2q4mode(3,2)=perf2q4mode(3,2)+length(find(q4test321{i}==2));
    perf2q4mode(3,3)=perf2q4mode(3,3)+length(find(q4test321{i}==3));
    
end