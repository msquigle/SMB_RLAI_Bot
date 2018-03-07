function readData(filename)
--Reads the external RL data file for a given level and loads it into a table and returns it
	local file = io.open("C:\\Users\\m_qui\\Documents\\School\\CMPUT 366\\NesEmu\\MyScripts\\SMBAreas\\smb3.2Data"..filename..".dat", "r")
	
	if(file ~= nil) then
		local table = {}
		for line in file:lines() do
			firstSpace = 1;
			temp = {};
			
			--Extract all data from a given line
			for i=1,23 do
				if(i == 23) then
					temp[i] = tonumber(line:sub(firstSpace+1));
				else
					secondSpace = line:find('%s',firstSpace+1)
					temp[i] = tonumber(line:sub(firstSpace,secondSpace-1));
					firstSpace = secondSpace
				end
			end
			
			--Add the line to the table
			if(table[temp[1]] == nil) then	
				table[temp[1]] = {};
			end

			if(table[temp[1]][temp[2]] == nil) then
				table[temp[1]][temp[2]] = {};
			end
			
			table[temp[1]][temp[2]][temp[3]] = {}
			
			for i=4,23 do
				table[temp[1]][temp[2]][temp[3]][i-3] = temp[i];
			end
		end
		io.close(file);
		return table;
	else
		print("File not found");
		return nil;
	end
end

function writeData(filename,data)
--Takes a ActionValue table and saves it in an external file that can be read by the readData function
	local file = io.open("C:\\Users\\m_qui\\Documents\\School\\CMPUT 366\\NesEmu\\MyScripts\\SMBAreas\\smb3.2Data"..filename..".dat", "w")
	--Loop through all states and record the action values for each action
	for i in pairs(data) do
		for j in pairs(data[i]) do
			for k in pairs(data[i][j]) do
				file:write(i,' ',j,' ',k,' ',data[i][j][k][1],' ',data[i][j][k][2],' ',data[i][j][k][3],' ',data[i][j][k][4],' ',data[i][j][k][5],' ',
						data[i][j][k][6],' ',data[i][j][k][7],' ',data[i][j][k][8],' ',data[i][j][k][9],' ',data[i][j][k][10],' ',data[i][j][k][11],' ',
						data[i][j][k][12],' ',data[i][j][k][13],' ',data[i][j][k][14],' ',data[i][j][k][15],' ',data[i][j][k][16],' ',
						data[i][j][k][17],' ',data[i][j][k][18],' ',data[i][j][k][19],' ',data[i][j][k][20],'\n')
			end
		end
	end
	io.close(file)
	timeofDay = os.date("*t",os.time());
	print("Saved "..filename.." at: "..timeofDay.hour..":"..timeofDay.min..":"..timeofDay.sec.." on "..timeofDay.month.."/"..timeofDay.day.."/"..timeofDay.year);
end

function createInputTable(action)
--Given a specific input it creates the table necessary for a given button combination
	inputTable = {A=false, up=false, left=false, B=false, select=false,right=false, down=false, start=false};
	
	if(action == 2) then
		inputTable.A = true;
		
	elseif(action == 3) then
		inputTable.B = true;
	
	elseif(action == 4) then
		inputTable.up = true;
		
	elseif(action == 5) then
		inputTable.right = true;
		
	elseif(action == 6) then
		inputTable.down = true;
		
	elseif(action == 7) then
		inputTable.left = true;
		
	elseif(action == 8) then
		inputTable.A = true;
		inputTable.up = true;
		
	elseif(action == 9) then
		inputTable.A = true;
		inputTable.right = true;
		
	elseif(action == 10) then
		inputTable.A = true;
		inputTable.down = true;
		
	elseif(action == 11) then
		inputTable.A = true;
		inputTable.left = true;
		
	elseif(action == 12) then
		inputTable.B = true;
		inputTable.up = true;
		
	elseif(action == 13) then
		inputTable.B = true;
		inputTable.right = true;
		
	elseif(action == 14) then
		inputTable.B = true;
		inputTable.down = true;
		
	elseif(action == 15) then
		inputTable.B = true;
		inputTable.left = true;
		
	elseif(action == 16) then
		inputTable.A = true;
		inputTable.B = true;
		
	elseif(action == 17) then
		inputTable.A = true;
		inputTable.B = true;
		inputTable.up = true;
		
	elseif(action == 18) then
		inputTable.A = true;
		inputTable.B = true;
		inputTable.right = true;
		
	elseif(action == 19) then
		inputTable.A = true;
		inputTable.B = true;
		inputTable.down = true;
		
	else
		inputTable.A = true;
		inputTable.B = true;
		inputTable.left = true;
		
	end
	
	return inputTable;
end

function retileUpdate(oldTable, newTiling)
--Quarters each current tile and copies the data to the new tiles
--Allows for quicker learning of more specific states
	for i in pairs(oldTable) do
		for j in pairs(oldTable[i]) do
			for k in pairs(oldTable[i][j]) do
				oldTable[i][j+newTiling] = {};
				oldTable[i][j+newTiling][k] = oldTable[i][j][k];
				oldTable[i][j+newTiling][k+newTiling] = oldTable[i][j][k];
				oldTable[i][j][k+newTiling] = oldTable[i][j][k];
			end
		end
	end
	return oldTable;
end

--START OF MAIN FUNCTION

--Set values for RL
alpha = 0.9;
gamma = 0.99;
epsilon = 0.01;
nSteps = 30;

--Set the starting world/level
world = 0;
level = 0;

--Episode to reduce Size and Grouping Size
red_episodes = 5000;
episode = 0;
tile_size = 16;

--Start lua script from the title screen
--This will skip the title screen and
--properly initialize the random
memory.writebyte(0x075F,world);
memory.writebyte(0x0760,level);
startTable = {A=false, up=false, left=false, B=false, select=false, right=false, down=false, start = false};
startTable.start = true;
joypad.write(1,startTable);
FCEU.frameadvance();
math.randomseed(os.time());
math.random();
math.random();
math.random();

--It took me too long to realize to put this in
FCEU.speedmode("turbo");

--Until we have control skip ahead
while(memory.readbyte(0x000E) ~= 7) do
	FCEU.frameadvance();
end
while(memory.readbyte(0x000E) ~= 8) do
	FCEU.frameadvance();
end

--Set the filename to save data as change as you see fit
--Checks if there is already that file and loads it
writeName = "W"..(world+1).."L"..(level+1);
temp = readData(writeName);
if(temp == nil) then
	actionValues = {};
else
	actionValues = temp;
end

--Using SARSA learning method
--Record values for proper storage and learning update
area = memory.readbyte(0x0750);
x = 255*memory.readbyte(0x006D) + memory.readbyte(0x0086);
x = (x - (x%tile_size));
y = memory.readbyte(0x00B5) * memory.readbyte(0x00CE);
y = y - (y%tile_size);


--Initialize the action value for a given state if it does not exist
--Could probably be cleaner but was throwing too many errors
--Initialize optimistically to encourage exploration
if(actionValues[area] == nil) then
	actionValues[area] = {};
	actionValues[area][x] = {}
	actionValues[area][x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10}
elseif(actionValues[area][x] == nil) then
	actionValues[area][x] = {};
	actionValues[area][x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
	
elseif(actionValues[area][x][y] == nil) then
	actionValues[area][x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
end
	
--Using epsilon greedy to select action
--Will update how epsilon changes throughout learning eventually
if(math.random() < epsilon) then
	lastAction = math.random(1,20);
	actionInput = createInputTable(lastAction);
else
	possibleActions = {1};
	maxValue = actionValues[area][x][y][1];
	for i=2,20 do
		if(actionValues[area][x][y][i] > maxValue) then
			possibleActions ={i};
			maxValue = actionValues[area][x][y][i];
			
		elseif(actionValues[area][x][y][i] == maxValue) then
			table.insert(possibleActions,i);
			
		end
	end
	if(#possibleActions == 1) then
		lastAction = possibleActions[1];
		actionInput = createInputTable(lastAction);
	else
		lastAction = possibleActions[math.random(1,#possibleActions)];
		actionInput = createInputTable(lastAction);
					  
	end	
end

nValues = {};
nValues[1] = {area,x,y,lastAction};
nSaved = 1;

saveTimer = 1;

--Begin learning loop
while(true) do
	--Sets timer and lives to avoid game overs due to time or deaths
	memory.writebyte(0x0787, 500);
	memory.writebyte(0x075A, 9);
	
	--Do latest action and get new state
	joypad.write(1,actionInput);
	FCEU.frameadvance();
	saveTimer  = saveTimer + 1;
		
	--Save after x iterations saving every ~15 mins with x = 1000000
	if(saveTimer >= 1000000) then
		writeData(writeName,actionValues);
		saveTimer = 1;
	end
	
	--Record new state values for learning update
	newarea = memory.readbyte(0x0750);
	newx = 255*memory.readbyte(0x006D) + memory.readbyte(0x0086);
	newx = (newx - (newx%tile_size));
	newy = memory.readbyte(0x00B5) * memory.readbyte(0x00CE);
	newy = newy - (newy%tile_size);
	
	--Initialize state if previously unseen
	if(actionValues[newarea] == nil) then
		actionValues[newarea] = {}
		actionValues[newarea][newx] = {};
		actionValues[newarea][newx][newy] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
		
	elseif(actionValues[newarea][newx] == nil) then
		actionValues[newarea][newx] = {};
		actionValues[newarea][newx][newy] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
		
	elseif(actionValues[newarea][newx][newy] == nil) then
		actionValues[newarea][newx][newy] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
	end
	
	--Select epsilon-greedy action
	if(math.random() < epsilon) then
		action = math.random(1,20);
		actionInput = createInputTable(action);
	else
		possibleActions = {1};
		maxValue = actionValues[newarea][newx][newy][1];
		for i=2,20 do
			if(actionValues[newarea][newx][newy][i] > maxValue) then
				possibleActions ={i};
				maxValue = actionValues[newarea][newx][newy][i];
				
			elseif(actionValues[newarea][newx][newy][i] == maxValue) then
				table.insert(possibleActions,i);
				
			end
		end
		if(#possibleActions == 1) then
			action = possibleActions[1];
			actionInput = createInputTable(action);
		else
			action = possibleActions[math.random(1,#possibleActions)];
			actionInput = createInputTable(action);
		end	
	end
	
	--Checks for death by falling or enemy impact or otherwise.
	if(memory.readbyte(0x000E) == 6 or memory.readbyte(0x000E) == 11) then
		while(memory.readbyte(0x000E) ~= 8) do
			FCEU.frameadvance();
		end
		
		for i = 1,nSteps do
			if(nValues[i] ~= nil) then
				G = 0;
				for j = i,nSteps do
					if(nValues[j] ~= nil) then
						G = G + -1*math.pow(gamma,j-i);
						lastMult = j-i;
					end
				end
				actionValues[nValues[i][1]][nValues[i][2]][nValues[i][3]][nValues[i][4]] = actionValues[nValues[i][1]][nValues[i][2]][nValues[i][3]][nValues[i][4]] +
				 alpha*(G + -10*math.pow(gamma,lastMult+1) - actionValues[nValues[i][1]][nValues[i][2]][nValues[i][3]][nValues[i][4]]);				
			end
		end
		--Update with reward -1 to encourage agent to accomplish in the shortest time
				
		--Learning update with reward -100 could be tested for better reward values
		area = memory.readbyte(0x0750);
		x = 255*memory.readbyte(0x006D) + memory.readbyte(0x0086);
		x = (x - (x%tile_size));
		y = memory.readbyte(0x00B5) * memory.readbyte(0x00CE);
		y = y - (y%tile_size);
		
		if(actionValues[area] == nil) then
			actionValues[area] = {};
			actionValues[area][x] = {};
			actionValues[area][x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
		
		elseif(actionValues[area][x] == nil) then
			actionValues[area][x] = {};
			actionValues[area][x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
			
		elseif(actionValues[area][x][y] == nil) then
			actionValues[area][x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
		end
			
		if(math.random() < epsilon) then
			lastAction = math.random(1,20);
			actionInput = createInputTable(lastAction);
		else
			possibleActions = {1};
			maxValue = actionValues[area][x][y][1];
			for i=2,20 do
				if(actionValues[area][x][y][i] > maxValue) then
					possibleActions ={i};
					maxValue = actionValues[area][x][y][i];
					
				elseif(actionValues[area][x][y][i] == maxValue) then
					table.insert(possibleActions,i);
					
				end
			end
			if(#possibleActions == 1) then
				lastAction = possibleActions[1];
				actionInput = createInputTable(lastAction);
			else
				lastAction = possibleActions[math.random(1,#possibleActions)];
				actionInput = createInputTable(lastAction);
							  
			end	
		end
		nValues = {};
		nValues[1] = {area,x,y,lastAction};
		nSaved = 1;
			
		--Increment newState -> lastState
	
	--Normal state change with nothing happening
	elseif(memory.readbyte(0x000E) == 8) then
		if(nValues[nSteps] ~= nil) then
			G = 0;
			for i = 1,(nSteps) do
				G = G + -1*math.pow(gamma,i-1);
			end
			actionValues[nValues[1][1]][nValues[1][2]][nValues[1][3]][nValues[1][4]] = actionValues[nValues[1][1]][nValues[1][2]][nValues[1][3]][nValues[1][4]] +
			 alpha*(G + math.pow(gamma,nSteps)*actionValues[newarea][newx][newy][action] - actionValues[nValues[1][1]][nValues[1][2]][nValues[1][3]][nValues[1][4]]);
			
			
			for i = 1,nSteps do
				if(nValues[i] ~= nil) then
					nValues[i] = nValues[i + 1];
				end
			end
			nSaved = nSaved - 1;
		end
		--Update with reward -1 to encourage agent to accomplish in the shortest time
		
		nSaved = nSaved + 1;
		nValues[nSaved] = {newarea,newx,newy,action};
		
	--This is when mario/luigi is going down the flag (level complete) need to test for bowser levels
	elseif(memory.readbyte(0x001D) == 3) then
	
		--Update with reward 3500, congratulations you finished a level, need to test different values for quicker convergence
		for i = 1,nSteps do
			if(nValues[i] ~= nil) then
				G = 0;
				for j = i,nSteps do
					if(nValues[j] ~= nil) then
						G = G + -1*math.pow(gamma,j-i);
						lastMult = j-i;
					end
				end
				actionValues[nValues[i][1]][nValues[i][2]][nValues[i][3]][nValues[i][4]] = actionValues[nValues[i][1]][nValues[i][2]][nValues[i][3]][nValues[i][4]] +
				 alpha*(G + math.pow(gamma,lastMult+1)*3500 - actionValues[nValues[i][1]][nValues[i][2]][nValues[i][3]][nValues[i][4]]);				
			end
		end
		--Update with reward -1 to encourage agent to accomplish in the shortest time
		
		--Save data to avoid loss after reaching the end of a level, in case we change levels
		writeData(writeName,actionValues);
		episode = episode + 1;
		print(episode);
		
		--If we have reached a set number of episodes reduce the tile size and if tile_size is at 1 change the level and reset tile_size
		if(episode == red_episodes) then
			episode = 0;
			if(tile_size ~= 1) then
				print("Reducing")
				tile_size = tile_size/2;
				actionValues = retileUpdate(actionValues, tile_size);
				writeData(writeName,actionValues);
			else
				tile_size = 16;
				level = level + 1;
				if(level == 4) then
					level = 0;
					world = world + 1;
					if(world == 8) then
						world = 0;
					end
				end	
			end
		end
		
		--Resets the game to quickly enter the next or same level
		FCEU.softreset();
		while(memory.readbyte(0x000E) ~= 8) do
			FCEU.frameadvance();
		end

		memory.writebyte(0x075F,world);
		memory.writebyte(0x0760,level);
		while(memory.readbyte(0x000E) ~= 7) do
			startTable = {A=false, up=false, left=false, B=false, select=false, right=false, down=false, start = false};
			joypad.write(1,startTable);
			FCEU.frameadvance();
			if(memory.readbyte(0x000e) == 7) then
				break;
			end		
			startTable = {A=false, up=false, left=false, B=false, select=false, right=false, down=false, start = false};
			startTable.start = true;
			joypad.write(1,startTable);
			FCEU.frameadvance();
		end
		FCEU.frameadvance();
		while(memory.readbyte(0x000E) ~= 8) do
			FCEU.frameadvance();
		end
		
		--Load given levels actionValues
		writeName = "W"..(world+1).."L"..(level+1);
		temp = readData(writeName);
		if(temp == nil) then
			actionValues = {};
		else
			actionValues = temp;
		end
		
		--Reselect starting point to update
		area = memory.readbyte(0x0750);
		x = 255*memory.readbyte(0x006D) + memory.readbyte(0x0086);
		x = (x - (x%tile_size));
		y = memory.readbyte(0x00B5) * memory.readbyte(0x00CE);
		y = y - (y%tile_size);
		
		if(actionValues[area] == nil) then
			actionValues[area] = {};
			actionValues[area][x] = {};
			actionValues[area][x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
		
		elseif(actionValues[area][x] == nil) then
			actionValues[area][x] = {};
			actionValues[area][x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
			
		elseif(actionValues[area][x][y] == nil) then
			actionValues[area][x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
		end
			
		if(math.random() < epsilon) then
			lastAction = math.random(1,20);
			actionInput = createInputTable(lastAction);
		else
			possibleActions = {1};
			maxValue = actionValues[area][x][y][1];
			for i=2,20 do
				if(actionValues[area][x][y][i] > maxValue) then
					possibleActions ={i};
					maxValue = actionValues[area][x][y][i];
					
				elseif(actionValues[area][x][y][i] == maxValue) then
					table.insert(possibleActions,i);
					
				end
			end
			if(#possibleActions == 1) then
				lastAction = possibleActions[1];
				actionInput = createInputTable(lastAction);
			else
				lastAction = possibleActions[math.random(1,#possibleActions)];
				actionInput = createInputTable(lastAction);
							  
			end	
		end
		nValues = {};
		nValues[1] = {area,x,y,lastAction};
		nSaved = 1;

	else
		--Any other event (pipes, who knows what else)
		while(memory.readbyte(0x000E) ~= 8) do
			FCEU.frameadvance();
		end
		
		if(nValues[nSteps] ~= nil) then
			G = 0;
			for i = 1,(nSteps) do
				G = G + -1*math.pow(gamma,i-1);
			end
			actionValues[nValues[1][1]][nValues[1][2]][nValues[1][3]][nValues[1][4]] = actionValues[nValues[1][1]][nValues[1][2]][nValues[1][3]][nValues[1][4]] +
			 alpha*(G + math.pow(gamma,nSteps)*actionValues[newarea][newx][newy][action] - actionValues[nValues[1][1]][nValues[1][2]][nValues[1][3]][nValues[1][4]]);
			
			
			for i = 1,nSteps do
				if(nValues[i] ~= nil) then
					nValues[i] = nValues[i + 1];
				end
			end
			nSaved = nSaved - 1;
		end
		--Update with reward -1 to encourage agent to accomplish in the shortest time
		
		nSaved = nSaved + 1;
		nValues[nSaved] = {newarea,newx,newy,action};

	end

end