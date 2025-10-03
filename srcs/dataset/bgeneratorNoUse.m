
f100=zeros(1,8);


for analysis = 1:18
    wavename = "femaleSad_"+analysis+".wav";
    f1(analysis) = funpitch(wavename);
    if f1(analysis)<100
      f100(1,1)=f100(1,1)+1;  
    elseif f1(analysis)>=100 && f1(analysis)<200 
        f100(1,2)=f100(1,2)+1;
    elseif f1(analysis)>=200 && f1(analysis)<300 
        f100(1,3)=f100(1,3)+1;
    elseif f1(analysis)>=300 && f1(analysis)<400 
        f100(1,4)=f100(1,4)+1;
    elseif f1(analysis)>=400 && f1(analysis)<500 
        f100(1,5)=f100(1,5)+1;
    elseif f1(analysis)>=500 && f1(analysis)<600 
        f100(1,6)=f100(1,6)+1;
    elseif f1(analysis)>=600 && f1(analysis)<700 
        f100(1,7)=f100(1,7)+1;
    else
        f100(1,8)=f100(1,8)+1;
    end
                
    
end
for analysis = 1:38
    wavename = "femalePositive_"+analysis+".wav";
    f2(analysis) = funpitch(wavename);
    if f2(analysis)<100
      f100(1,1)=f100(1,1)+1;  
    elseif f2(analysis)>=100 && f2(analysis)<200 
        f100(1,2)=f100(1,2)+1;
    elseif f2(analysis)>=200 && f2(analysis)<300 
        f100(1,3)=f100(1,3)+1;
    elseif f2(analysis)>=300 && f2(analysis)<400 
        f100(1,4)=f100(1,4)+1;
    elseif f2(analysis)>=400 && f2(analysis)<500 
        f100(1,5)=f100(1,5)+1;
    elseif f2(analysis)>=500 && f2(analysis)<600 
        f100(1,6)=f100(1,6)+1;
    elseif f2(analysis)>=600 && f2(analysis)<700 
        f100(1,7)=f100(1,7)+1;
    else
        f100(1,8)=f100(1,8)+1;
    end
    
    
end
for analysis = 1:36
    wavename = "femaleAngry_"+analysis+".wav";
    f3(analysis) = funpitch(wavename);
    if f3(analysis)<100
      f100(1,1)=f100(1,1)+1;  
    elseif f3(analysis)>=100 && f3(analysis)<200 
        f100(1,2)=f100(1,2)+1;
    elseif f3(analysis)>=200 && f3(analysis)<300 
        f100(1,3)=f100(1,3)+1;
    elseif f3(analysis)>=300 && f3(analysis)<400 
        f100(1,4)=f100(1,4)+1;
    elseif f3(analysis)>=400 && f3(analysis)<500 
        f100(1,5)=f100(1,5)+1;
    elseif f3(analysis)>=500 && f3(analysis)<600 
        f100(1,6)=f100(1,6)+1;
    elseif f3(analysis)>=600 && f3(analysis)<700 
        f100(1,7)=f100(1,7)+1;
    else
        f100(1,8)=f100(1,8)+1;
    end
    
    
end
