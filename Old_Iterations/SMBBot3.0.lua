function readData(filename)
	local file = io.open("C:\\Users\\m_qui\\Documents\\School\\CMPUT 366\\NesEmu\\MyScripts\\SMBAreas\\smb3.1Data"..filename..".dat", "r")
	
	if(file ~= nil) then
		local table = {}
		for line in file:lines() do
			firstSpace = 1;
			temp = {};
			
			for i=1,23 do
				if(i == 23) then
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
	local file = io.open("C:\\Users\\m_qui\\Documents\\School\\CMPUT 366\\NesEmu\\MyScripts\\SMBAreas\\smb3.1Data"..filename..".dat", "w")
	for i in pairs(data) do
		for j in pairs(data[i]) do
			for k in pairs(data[i][j]) do
				file:write(i,' ',j,' ',k,' ',data[i][j][k][1],' ',data[i][j][k][2],' ',data[i][j][k][3],' ',data[i][j][k][4],' ',data[i][j][k][5],' ',
						data[i][j][k][6],' ',data[i][j][k][7],' ',data[i][j][k][8],' ',data[i][j][k][9],' ',data[i][j][k][10],' ',data[i][j][k][11],' ',
						data[i][j][k][12],' ',data[i][j][k][13],' ',data[i][j][k][14],' ',data[i][j][k][15],' ',data[i][j][k][16],' ',
						data[i][j][k][17],' ',data[i][j][k][18],' ',data[i][j][k][19],' ',data[i][j][k][20],'\n')
		end
	end
	io.close(file)
	timeofDay = os.date("*t",os.time());
	print("Saved "..filename.." at: "..timeofDay.hour..":"..timeofDay.min..":"..timeofDay.sec.." on "..timeofDay.month.."/"..timeofDay.day.."/"..timeofDay.year);
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
--Episode to reduce Size and Grouping Size
red_episodes = 5000;
episode = 0;
tile_size = 16;

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
while(memory.readbyte(0x000E) ~= 8) do
	FCEU.frameadvance();
end


writeName = "W"..(world+1).."L"..(level+1);
temp = readData(writeName);
if(temp == nil) then
	actionValues = {};
else
	actionValues = temp;
end

area = memory.readbyte(0x0750);
x = 255*memory.readbyte(0x006D) + memory.readbyte(0x0086);
x = (x - (x%tile_size));
y = memory.readbyte(0x00B5) * memory.readbyte(0x00CE);
y = y - (y%tile_size);

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
saveTimer = 1;

while(true) do
	memory.writebyte(0x0787, 500);
	memory.writebyte(0x075A, 9);
	
	joypad.write(1,actionInput);
	FCEU.frameadvance();
		
	if(saveTimer >= 1000000) then
		writeData(writeName,actionValues);
		saveTimer = 1;
	end
	saveTimer = saveTimer + 1;
	
	newarea = memory.readbyte(0x0750);
	newx = 255*memory.readbyte(0x006D) + memory.readbyte(0x0086);
	newx = (newx - (newx%tile_size));
	newy = memory.readbyte(0x00B5) * memory.readbyte(0x00CE);
	newy = newy - (newy%tile_size);
	
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
	
	if(memory.readbyte(0x000E) == 6 or memory.readbyte(0x000E) == 11) then
		while(memory.readbyte(0x000E) ~= 8) do
			FCEU.frameadvance();
		end
				
		actionValues[area][x][y][lastAction] = actionValues[area][x][y][lastAction] + alpha*(-100 + gamma*actionValues[newarea][newx][newy][action] - actionValues[area][x][y][lastAction])
	
		area = newarea;
		x = newx;
		y = newy;
		lastAction = action;
		
	elseif(memory.readbyte(0x000E) == 8) then

		actionValues[area][x][y][lastAction] = actionValues[area][x][y][lastAction] + alpha*(-1 + gamma*actionValues[newarea][newx][newy][action] - actionValues[area][x][y][lastAction])

		area = newarea;
		x = newx;
		y = newy;
		lastAction = action;
		
	elseif(memory.readbyte(0x001D) == 3) then
		actionValues[area][x][y][lastAction] = actionValues[area][x][y][lastAction] + alpha*(3500 + gamma*actionValues[newarea][newx][newy][action] - actionValues[area][x][y][lastAction])

		writeData(writeName,actionValues);
		episode = episode + 1;
		
		if(episode == red_episodes) then
			episode = 0;
			if(tile_size ~= 1) then
				tile_size = tile_size/2;
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
		
		writeName = "W"..(world+1).."L"..(level+1)t;
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

	else
		while(memory.readbyte(0x000E) ~= 8) do
			FCEU.frameadvance();
		end
		
		actionValues[area][x][y][lastAction] = actionValues[area][x][y][lastAction] + alpha*(-1 + gamma*actionValues[newarea][newx][newy][action] - actionValues[area][x][y][lastAction])
		
		area = newarea;
		x = newx;
		y = newy;
		lastAction = action;

	end

end