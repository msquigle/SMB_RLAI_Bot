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