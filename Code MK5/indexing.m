function [isBack, isFront] = indexing(numsec, numact, nf, nb)

actuator = zeros(numact, 2);
actuator(:,1) = linspace(1,numact,numact);   % first columns is for number of section in the back

for i = 1:numact
    actuator(i,2) = numsec - actuator(i,1);     % second column is for section in the front.
end

isBack = zeros(numact,1);
isFront = zeros(numact,1);

for j = 1:numact
    isBack(j) = j-nb+1;
    if isBack(j) <= 0
        isBack(j) = actuator(j,1);
    end
    
    isFront(j) = j+nf;
    if isFront(j) > numsec
        isFront(j) = j + actuator(j,2);
    end
end
end
