function estimated = Lagrange_2( sp3_times,sp3_coordinates,te )
%Input:
% sp3_times is the vector of SP3 EPOCH
% sp3_coordinates is the vector of SP3 X or Y or Z or clock error
% te is the emission time which we wont to calculate the coordinates of satellite on this epoch 

%Output:
%estimated is the vector contains the estimated X or Y or Z or clock error

n=length(sp3_times);

if size(sp3_times,1) > 1
    sp3_times = sp3_times' ;
end 

if size(sp3_coordinates,1) > 1
	sp3_coordinates= sp3_coordinates';
end

if size(sp3_times,1) > 1 || size(sp3_coordinates,1) > 1 || size(sp3_times,2) ~= size(sp3_coordinates,2)
	error('Both inputs must be same length vectors') 
end

polinom=ones(n,length(te));
for i=1:n
    for j=1:n
        if j~=i
           polinom(i,:)=polinom(i,:).*(te-sp3_times(j))./(sp3_times(i)-sp3_times(j));
        end
    end
end
estimated=sp3_coordinates*polinom;
end