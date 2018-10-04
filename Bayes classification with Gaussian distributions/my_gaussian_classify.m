function [Cpreds, Ms, Covs] = my_gaussian_classify(Xtrn, Ctrn, Xtst, epsilon)
% Construct the needed matrices
n = size(Xtst, 1);
Cpreds = zeros(n, 1);
d = size(Xtst,2);
k = 26;
Ms = zeros(d,k);
Covs = zeros(d,d,k);
classNumber = zeros(26,1);
classAcc = zeros(n,26);
%Find the number of vectors for each class
for i=1:size(Ctrn,1)
    classNumber(Ctrn(i)) = classNumber(Ctrn(i)) + 1;
end
% Go through each class
for i=1:26
    %Take the vectors from each class
    classMatrix = Xtrn(Ctrn(:,1) == i, :);
    % Compute the mean vector
    Ms(:,i) = myMean(classMatrix);
    % Subtracting the mean 
    classMatrix = classMatrix - Ms(:,i)';
    % Computing the cov matrix
    Covs(:,:,i) = myCov(classMatrix);
    % Reegulate the matrix so we can compute the inverse one
    Covs(:,:,i) = Covs(:,:,i) + eye(size(Covs(:,:,i))) .* epsilon;
    inverseMatrix = (inv(Covs(:,:,i)));
    covMatrixDet = logdet(Covs(:,:,i));
    % Go though each test vector
    for j=1:n
        % We are using the log operation, because the probabilities can
        % become really small when working with big data and can cause
        % an underflow
        classAcc(j,i) = (Xtst(j,:) - Ms(:,i)') * inverseMatrix * (Xtst(j,:) - Ms(:,i)')' ./ (-2) - covMatrixDet ./ 2;
    end
end
[~,index] = sort(classAcc,2, 'descend');
Cpreds(:) = index(:,1);
end