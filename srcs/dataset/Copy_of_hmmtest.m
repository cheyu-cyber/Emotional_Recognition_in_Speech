close, clc, clear all
for analysis = 1:16
    wavename = "femaleSad_"+analysis+".wav";
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
    outputnn11 = [1; 0; 0];
    for i=1:length(input11)-1
        outputnn11 = horzcat(outputnn11, [1;0;0]);
    end
    outputnn12 = [1; 0; 0];
    for i=1:length(input12)-1
        outputnn12 = horzcat(outputnn12, [1;0;0]);
    end
end
for analysis=1:3
    wavename = "femaleSad_train"+analysis+".wav";
    [CM, delCM, YM, delYM]=mfccfunc(wavename);
    test11{analysis} = CM;
    test12{analysis} = delCM;
    test13{analysis} = YM;
    test14{analysis} = delYM;
    if analysis==1
        testnn11 = CM;
        testnn12 = delCM;
        testnn13 = YM;
        testnn14 = delYM;
    else
        testnn11 = vertcat(testnn11, CM);
        testnn12 = vertcat(testnn12, delCM);
        testnn13 = vertcat(testnn13, YM);
        testnn14 = vertcat(testnn14, delYM);
    end
end

for analysis = 1:39
    wavename = "femalePositive_"+analysis+".wav";
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
    
    outputnn21 = [0; 1; 0];
    for i=1:length(input21)-1
        outputnn21 = horzcat(outputnn21, [0;1;0]);
    end
    outputnn22 = [0; 1; 0];
    for i=1:length(input22)-1
        outputnn22 = horzcat(outputnn22, [0;1;0]);
    end
end
for analysis=1:5
    wavename = "femalePositive_train"+analysis+".wav";
    [CM, delCM, YM, delYM]=mfccfunc(wavename);
    test21{analysis} = CM;
    test22{analysis} = delCM;
    test23{analysis} = YM;
    test24{analysis} = delYM;
    if analysis==1
        testnn21 = CM;
        testnn22 = delCM;
        testnn23 = YM;
        testnn24 = delYM;
    else
        testnn21 = vertcat(testnn21, CM);
        testnn22 = vertcat(testnn22, delCM);
        testnn23 = vertcat(testnn23, YM);
        testnn24 = vertcat(testnn24, delYM);
    end
end
for analysis = 1:32
    wavename = "femaleAngry_"+analysis+".wav";
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
    
    outputnn31 = [0; 0; 1];
    for i=1:length(input31)-1
        outputnn31 = horzcat(outputnn31, [0;0;1]);
    end
    outputnn32 = [0; 0; 1];
    for i=1:length(input32)-1
        outputnn32 = horzcat(outputnn32, [0;0;1]);
    end
   
end
for analysis=1:4
    wavename = "femaleAngry_train"+analysis+".wav";
    [CM, delCM, YM, delYM]=mfccfunc(wavename);
    test31{analysis} = CM;
    test32{analysis} = delCM;
    test33{analysis} = YM;
    test34{analysis} = delYM;
    if analysis==1
        testnn31 = CM;
        testnn32 = delCM;
        testnn33 = YM;
        testnn34 = delYM;
    else
        testnn31 = vertcat(testnn31, CM);
        testnn32 = vertcat(testnn32, delCM);
        testnn33 = vertcat(testnn33, YM);
        testnn34 = vertcat(testnn34, delYM);
    end
end
inputnnfemale1 = vertcat(input11, input21, input31).';
inputnnfemale2 = vertcat(input12, input22, input32).';
inputnnfemale3 = vertcat(input13, input23, input33).';
inputnnfemale4 = vertcat(input14, input24, input34).';
testnn11=testnn11.';testnn12=testnn12.';testnn21=testnn21.';testnn22=testnn22.';testnn31=testnn31.';testnn32=testnn32.';
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
outputnnfemale1 = horzcat(outputnn11, outputnn21, outputnn31);
outputnnfemale2 = horzcat(outputnn12, outputnn22, outputnn32);
for i = 1:16
    [aest1{i}, best1{i}]= hmmestimate(input1(1:end, i), output1);
    [aest2{i}, best2{i}]= hmmestimate(input2(1:end, i), output2);
    [aest3{i}, best3{i}]= hmmestimate(input3(1:end, i), output1);
    [aest4{i}, best4{i}]= hmmestimate(input4(1:end, i), output2);   
    best1{i} = horzcat(best1{i}, zeros(3,20));
    best2{i} = horzcat(best2{i}, zeros(3,20));
   % ob{i} = (round(test11{4}(1:end,i)*2)+50).';
   % [pstate{i}, pseq{i}, fs{i}, bs{i}, s{i}] = hmmdecode(ob{i}, aest1{i}, best1{i});
  %  [atrain1{i}, btrain1{i}]= hmmtrain(ob{i}, aest1{i}, best1{i});
end
perf11=0;perf12=0;perf13=0;
for i = 1:3
[q11{i}, q2test11{i}, q4test11{i}, fP111{i}, fP211{i}, P111{i}, P211{i}] = hmm(test11{i}, aest1, best1);
for j = 1:16
    q111{i}(j) = mode(q11{i}{j}(:));    
    q2test111{i}(j) = mode(q2test11{i}{j}(:)); 
    q4test111{i}(j) = mode(q4test11{i}{j}(:)); 
    perf11=perf11+length(find(q11{i}{j}==1));
    perf12=perf12+length(find(q11{i}{j}==2));
    perf13=perf13+length(find(q11{i}{j}==3));
end

end
perf21=0;perf22=0;perf23=0;
for i = 1:5
[q21{i}, q2test21{i}, q4test21{i},fP121{i}, fP221{i}, P121{i}, P221{i}] = hmm(test21{i}, aest1, best1);
for j = 1:16
    q211{i}(j) = mode(q21{i}{j}(:));
    q2test211{i}(j) = mode(q2test21{i}{j}(:)); 
    q4test211{i}(j) = mode(q4test21{i}{j}(:)); 
    perf21=perf21+length(find(q21{i}{j}==1));
    perf22=perf22+length(find(q21{i}{j}==2));
    perf23=perf23+length(find(q21{i}{j}==3));    
end

end
perf31=0;perf32=0;perf33=0;
for i = 1:4
[q31{i}, q2test31{i}, q4test31{i},fP131{i}, fP231{i}, P131{i}, P231{i}] = hmm(test31{i}, aest1, best1);
for j = 1:16
    q311{i}(j) = mode(q31{i}{j}(:));
    q2test311{i}(j) = mode(q2test31{i}{j}(:)); 
    q4test311{i}(j) = mode(q4test31{i}{j}(:)); 
    perf31=perf31+length(find(q31{i}{j}==1));
    perf32=perf32+length(find(q31{i}{j}==2));
    perf33=perf33+length(find(q31{i}{j}==3));
end
    
end
per11=0;per12=0;per13=0;
for i = 1:3
[q12{i}, q2test12{i}, q4test12{i},fP112{i}, fP212{i}, P112{i}, P212{i}] = hmm(test12{i}, aest2, best2);
for j = 1:16
    q121{i}(j) = mode(q12{i}{j}(:));
    q2test121{i}(j) = mode(q2test12{i}{j}(:)); 
    q4test121{i}(j) = mode(q4test12{i}{j}(:)); 
    per11=per11+length(find(q12{i}{j}==1));
    per12=per12+length(find(q12{i}{j}==2));
    per13=per13+length(find(q12{i}{j}==3));
end
    
end
per21=0;per22=0;per23=0;
for i = 1:5
[q22{i}, q2test22{i}, q4test22{i}, fP122{i}, fP222{i}, P122{i}, P222{i}] = hmm(test22{i}, aest2, best2);
for j = 1:16
    q221{i}(j) = mode(q22{i}{j}(:));
    q2test221{i}(j) = mode(q2test22{i}{j}(:)); 
    q4test221{i}(j) = mode(q4test22{i}{j}(:)); 
    per21=per21+length(find(q22{i}{j}==1));
    per22=per22+length(find(q22{i}{j}==2));
    per23=per23+length(find(q22{i}{j}==3));
end
    
end
per31=0;per32=0;per33=0;
for i = 1:4
[q32{i}, q2test32{i}, q4test32{i}, fP132{i}, fP232{i}, P132{i}, P232{i}] = hmm(test32{i}, aest2, best2);
for j = 1:16
    q321{i}(j) = mode(q32{i}{j}(:));
    q2test321{i}(j) = mode(q2test32{i}{j}(:)); 
    q4test321{i}(j) = mode(q4test32{i}{j}(:)); 
    per31=per31+length(find(q32{i}{j}==1));
    per32=per32+length(find(q32{i}{j}==2));
    per33=per33+length(find(q32{i}{j}==3));
end
    
end


    
