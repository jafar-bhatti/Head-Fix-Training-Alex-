function habituation(params)
KbName('UnifyKeyNames');
delete(instrfindall);

% load the arduino sketch
if params.inverted
    hexPath = [params.hex filesep 'habituation_inv.ino.hex'];
else
    hexPath = [params.hex filesep 'habituation.ino.hex'];
end
loadArduinoSketch(params.com,hexPath);

% open the serial port
p = setupSerialPort(params.com,9600);

% start habituation
cnt = 0;
while cnt < 1e6
    out = serialRead(p,params.boothID);
    fprintf('%s\n',out);
    
    % Once started, send variables to arduino
    if ~isempty(regexp(out,'STARTING', 'once'))
        % send setup variables to the arduino
        varvect = [params.holdD params.rewardDuration params.debounceTime];
        fprintf(p,'%f %f %d ',varvect);
    elseif ~isempty(regexp(out,'USEREXIT', 'once'))
        break;
    end
    
    cnt = cnt + 1;
end

delete(p);

% load a blank arduino sketch
hexPath = [params.hex filesep 'blank.ino.hex'];
loadArduinoSketch(params.com,hexPath);


