clc
clear
close
%% CR calculation of a given match
filename = 'testData.xlsx';
data = importingMatchData(filename); % imports the testing statistics of all the matches
% Allocate imported array to column variable names
Match = data(:,1);
Runs = data(:,2);
Sixes = data(:,3);
Fours = data(:,4);
Balls = data(:,5);
NotOutC = data(:,6);
Overs = data(:,7);
Wickets = data(:,8);
Runs1 = data(:,9);
Catches = data(:,10);
Stumpings = data(:,11);
RunOuts = data(:,12);
clearvars data;

CR = zeros(length(Match),1);

for i = 1:1:length(Match)
    % base credit score
    CR(i) = Runs(i) + 20*Wickets(i) + 10*Catches(i) + 15*Stumpings(i) + 10*RunOuts(i);
    
    
    % changes with respect to the strike rate of the batsman
    if Balls(i) > 20 
        
        Sr = Runs(i)/Balls(i)*100;
        
        if Sr > 200
            CR(i) = 1.15*CR(i);
        else if Sr > 150
                CR(i)= 1.1*CR(i);
            else if Sr > 100
                    CR(i)= 1.05*CR(i);
                else if Sr > 75
                        CR(i)= 1.025*CR(i);
                    else CR(i)= 0.5*CR(i);
                    end
                end
            end
        end

        % changes because of boundaries hit
        eta = Fours(i)*5 + Sixes(i)*10;
        CR(i)= CR(i)+ eta;

        % score milestones add 10 points for every 50 runs scored
        % k is the rounded off quotient to the last integer. k is 1 for runs 50
        % to 99, 2 for 100 to 149 and so on.  
        k = round(Runs(i)/50);
        if k > Runs(i)/50
            k = k- 1;
        end
        CR(i)= CR(i)+ 10*k;

        % if the player is not-out then add another 20
        if NotOutC(i) == 1
            CR(i)= CR(i)+ 20;
        end
        
    end % else if loop only if the player has played at-least 20 balls
    
    
    % else if loop only if the player has bowled at-least 2 overs
    if Overs(i) > 2
        % changes with respect to the economy of the bowler
        eco = Runs1(i)/Overs(i);
        if eco >= 10
            CR(i) = CR(i) - 15;
        else if eco > 7.5
                CR(i)= CR(i) - 10;
            else if eco > 6
                    CR(i)= CR(i) - 5;
                else if eco > 3
                        CR(i)= CR(i) + 7.5;
                    else CR(i)= CR(i) + 15;
                    end
                end
            end
        end
        
        % wicket milestones add 10 points for every 3 wickets taken
        % k is the rounded off quotient to the last integer. k is 1 for
        % wicket 3 to 6 2 for 6 to 9 and so on.
        k = round(Wickets(i)/3);
        if k > Wickets(i)/3
            k = k- 1;
        end
        CR(i)= CR(i)+ 20*k;
        
        
    end % else if loop only if the player has bowled at-least 2 overs                
    if CR(i) > 500 
        CR(i) = 1;
    else if CR(i) > 250 
        CR(i) = 0.75;
        else if CR(i) > 125 
        CR(i) = 0.5;
            else CR(i) = 0.25;
            end
        end
    end
            
end

% X matrix has been arranged as [RUNS BattingAverage StrikeRate centuries fifties 
%                                Wickets BowlingAverage economy 3-wktHauls Catches Stumpings RO OPPO1 OPPO2 OPPO3 OPPO4 OPPO5 OPPO6]  
X = zeros(200,18);
counter = 0;
for i = 101:1:300
    counter = counter + 1;
    X(counter,1) = sum(Runs(1:i-1)); % runs in i - 1 matches.. 
    X(counter,2) = sum(Runs(1:i-1))/(i-1-nnz(NotOutC(1:i-1))); % batting average of i - 1 matches.. 
    X(counter,3) = sum(Runs(1:i-1))/sum(Balls(1:i-1))*100; % strike rate of i - 1 matches .. 
    X(counter,4) = sum(Runs(1:i-1) >= 100); % centuries... 
    X(counter,5) = sum(Runs(1:i-1) >= 50) - X(counter,3); % fifties... 
    X(counter,6) = sum(Wickets(1:i-1)); % wickets taken... 
    X(counter,7) = (sum(Runs1(1:i-1))/sum(Wickets(1:i-1)))^-1; % bowling average... lower the better..
    X(counter,8) = (sum(Runs1(1:i-1))/sum(Overs(1:i-1)))^-1; % economy... lower the better... 
    X(counter,9) = sum(Wickets(1:i-1) >= 3); % centuries... 
    X(counter,10) = sum(Catches(1:i-1)); % catxhes taken... 
    X(counter,11) = sum(Stumpings(1:i-1)); % stumppings done... 
    X(counter,12) = sum(RunOuts(1:i-1)); % run outs involved in...
    k = randi(6); % randomly select one of the 6 opponents -- THIS DATA MUST ALSO BE PROVIDED BEFOREHAND
    X(counter,12+k) = 1;
end

P = regress(CR(101:300),X);

