function readData(filename)
	local file = io.open("C:\\Users\\m_qui\\Documents\\School\\CMPUT 366\\NesEmu\\MyScripts\\smb2.0Data"..filename..".dat", "r")
	
	if(file ~= nil) then
		local table = {}
		for line in file:lines() do
			firstSpace = 1;
			temp = {};
			
			for i=1,22 do
				if(i == 22) then
					temp[i] = tonumber(line:sub(firstSpace+1));
				else
					secondSpace = line:find('%s',firstSpace+1)
					temp[i] = tonumber(line:sub(firstSpace,secondSpace-1));
					firstSpace = secondSpace
				end
			end
			
			if(table[temp[1]] == nil) then	
				table[temp[1]] = {};
			end

			table[temp[1]][temp[2]] = {};
			
			for i=3,22 do
				table[temp[1]][temp[2]][i-2] = temp[i];
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
	local file = io.open("C:\\Users\\m_qui\\Documents\\School\\CMPUT 366\\NesEmu\\MyScripts\\smb2.0Data"..filename..".dat", "w")
	for i in pairs(data) do
		for j in pairs(data[i]) do
			file:write(i,' ',j,' ',data[i][j][1],' ',data[i][j][2],' ',data[i][j][3],' ',data[i][j][4],' ',data[i][j][5],' ',
						data[i][j][6],' ',data[i][j][7],' ',data[i][j][8],' ',data[i][j][9],' ',data[i][j][10],' ',data[i][j][11],' ',
						data[i][j][12],' ',data[i][j][13],' ',data[i][j][14],' ',data[i][j][15],' ',data[i][j][16],' ',
						data[i][j][17],' ',data[i][j][18],' ',data[i][j][19],' ',data[i][j][20],'\n')
		end
	end
	io.close(file)
	timeofDay = os.date("*t",os.time());
	print("Saved at: "..timeofDay.hour..":"..timeofDay.min..":"..timeofDay.sec.." on "..timeofDay.month.."/"..timeofDay.day.."/"..timeofDay.year);
end

function createInputTable(action)
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

--START OF MAIN FUNCTION
alpha = 0.9;
gamma = 0.99;
epsilon = 0.01;
--Worlds and Levels indexed from 0
world = 0;
level = 0;
levelSelect = "W"..(world+1).."L"..(level+1)
--Episode to reduce Size and Grouping Size
red_episodes = 5000;
episode = 0;
tile_size = 16;
offset_room = 1; --Multiplier for different areas

temp = readData(levelSelect);
if(temp == nil) then
	actionValues = {};
else
	actionValues = temp;
end
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

FCEU.speedmode("turbo");

while(memory.readbyte(0x000E) ~= 7) do
	FCEU.frameadvance();
end

x = 255*memory.readbyte(0x006D) + memory.readbyte(0x0086);
x = offset_room*(x - (x%tile_size));
y = memory.readbyte(0x00B5) * memory.readbyte(0x00CE);
y = y - (y%tile_size);

if(actionValues[x] == nil) then
	actionValues[x] = {};
	actionValues[x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
	
elseif(actionValues[x][y] == nil) then
	actionValues[x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
end
	
if(math.random() < epsilon) then
	lastAction = math.random(1,20);
	actionInput = createInputTable(lastAction);
else
	possibleActions = {1};
	maxValue = actionValues[x][y][1];
	for i=2,20 do
		if(actionValues[x][y][i] > maxValue) then
			possibleActions ={i};
			maxValue = actionValues[x][y][i];
			
		elseif(actionValues[x][y][i] == maxValue) then
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
saveTimer = 1;

while(true) do
	memory.writebyte(0x0787, 500);
	memory.writebyte(0x075A, 9);
	
	joypad.write(1,actionInput);
	FCEU.frameadvance();
	if(saveTimer == 1000000) then
		writeData(levelSelect,actionValues);
		saveTimer = 1;
	end
	saveTimer = saveTimer + 1;
	
	newx = 255*memory.readbyte(0x006D) + memory.readbyte(0x0086);
	newx = offset_room*(newx - (newx%tile_size));
	newy = memory.readbyte(0x00B5) * memory.readbyte(0x00CE);
	newy = newy - (newy%tile_size);
	
	if(actionValues[newx] == nil) then
		actionValues[newx] = {};
		actionValues[newx][newy] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
		
	elseif(actionValues[newx][newy] == nil) then
		actionValues[newx][newy] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
	end
	
	if(math.random() < epsilon) then
		action = math.random(1,20);
		actionInput = createInputTable(action);
	else
		possibleActions = {1};
		maxValue = actionValues[newx][newy][1];
		for i=2,20 do
			if(actionValues[newx][newy][i] > maxValue) then
				possibleActions ={i};
				maxValue = actionValues[newx][newy][i];
				
			elseif(actionValues[newx][newy][i] == maxValue) then
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
	
	--deltaPos = newx - x;

	
	if(memory.readbyte(0x000E) == 6 or memory.readbyte(0x000E) == 11) then
		actionValues[x][y][lastAction] = actionValues[x][y][lastAction] + alpha*(-100 + gamma*actionValues[newx][newy][action] - actionValues[x][y][lastAction])
		while(memory.readbyte(0x000E) ~= 8) do
			FCEU.frameadvance();
		end
		x = 255*memory.readbyte(0x006D) + memory.readbyte(0x0086);
		x = offset_room*(x - (x%tile_size));
		y = memory.readbyte(0x00B5) * memory.readbyte(0x00CE);
		y = y - (y%tile_size);
		
		if(actionValues[x] == nil) then
			actionValues[x] = {};
			actionValues[x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
			
		elseif(actionValues[x][y] == nil) then
			actionValues[x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
		end
			
		if(math.random() < epsilon) then
			lastAction = math.random(1,20);
			actionInput = createInputTable(lastAction);
		else
			possibleActions = {1};
			maxValue = actionValues[x][y][1];
			for i=2,20 do
				if(actionValues[x][y][i] > maxValue) then
					possibleActions ={i};
					maxValue = actionValues[x][y][i];
					
				elseif(actionValues[x][y][i] == maxValue) then
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
	
	elseif(memory.readbyte(0x000E) == 8) then
		actionValues[x][y][lastAction] = actionValues[x][y][lastAction] + alpha*(-1 + gamma*actionValues[newx][newy][action] - actionValues[x][y][lastAction])
		x = newx;
		y = newy;
		lastAction = action;
		
	elseif(memory.readbyte(0x001D) == 3) then
		actionValues[x][y][lastAction] = actionValues[x][y][lastAction] + alpha*(3500 + gamma*actionValues[newx][newy][action] - actionValues[x][y][lastAction])
		writeData(levelSelect,actionValues);
		episode = episode + 1;
		
		if(episode == red_episodes) then
			episode = 0;
			if(tile_size ~= 1) then
				tile_size = tile_size/2;
			end
		end
		
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
		--Reselect starting point to update
		x = 255*memory.readbyte(0x006D) + memory.readbyte(0x0086);
		x = offset_room*(x - (x%tile_size));
		y = memory.readbyte(0x00B5) * memory.readbyte(0x00CE);
		y = y - (y%tile_size);
		
		if(actionValues[x] == nil) then
			actionValues[x] = {};
			actionValues[x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
			
		elseif(actionValues[x][y] == nil) then
			actionValues[x][y] = {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10};
		end
			
		if(math.random() < epsilon) then
			lastAction = math.random(1,20);
			actionInput = createInputTable(lastAction);
		else
			possibleActions = {1};
			maxValue = actionValues[x][y][1];
			for i=2,20 do
				if(actionValues[x][y][i] > maxValue) then
					possibleActions ={i};
					maxValue = actionValues[x][y][i];
					
				elseif(actionValues[x][y][i] == maxValue) then
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

	else
		actionValues[x][y][lastAction] = actionValues[x][y][lastAction] + alpha*(-1 + gamma*actionValues[newx][newy][action] - actionValues[x][y][lastAction])
		offset_changed = 0;
		while(memory.readbyte(0x000E) ~= 8) do
			if(memory.readbyte(0x000E) == 2 or memory.readbyte(0x000E) == 3) then
				if(offset_changed == 0) then
					if(offset_room == -1) then
						offset_room = 1;
					else
						offset_room = -1;
					end
					offset_changed = 1;
				end
			end
			FCEU.frameadvance();
		end
		x = newx;
		y = newy;
		lastAction = action;
	end
	
	
	if(memory.readbyte(0x000E)== 6) then
		while(memory.readbyte(0x000E) ~= 8) do
			FCEU.frameadvance();
		end
	end

end