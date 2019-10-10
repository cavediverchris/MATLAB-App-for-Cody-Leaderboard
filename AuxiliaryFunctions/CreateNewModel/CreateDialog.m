function [NewModelName] = CreateDialog(CombinedArray, FirstPrefix)
%CREATEDIALOG Summary of this function goes here
%   Detailed explanation goes here

% Initialise temporary values
choice = 'TBD';
name = 'TBD2';

dlg = dialog('Position', [300 300 500 150],'Name','Specify New Model Name');

    buttonGroup = uibuttongroup('parent', dlg, ...
                    'Visible', 'off', ...
                    'Position', [0 0 .3 1]);
                
    rad1 = uicontrol(buttonGroup, ...
            'Style', 'radiobutton', ...
            'Position',[10 50 100 30],...
            'String','Simulink Model');
        
    rad2 = uicontrol(buttonGroup, ...
            'Style', 'radiobutton', ...
            'Position',[10 100 100 30],...
            'String','MATLAB Script');

    buttonGroup.Visible = 'on';
    
    txt1 = uicontrol('Parent',dlg,...
            'Style','text',...
            'Position',[175 100 100 25],...
            'String','Select a prefix');
       
    popup = uicontrol('Parent',dlg,...
            'Style','popup',...
            'Position',[175 75 100 25],...
            'String',CombinedArray, ...;
            'Callback', @popup_callback);
        %'String',{'Red','Green','Blue'});
            
            

    txt2 = uicontrol('Parent',dlg,...
            'Style','text',...
            'Position',[300 85 110 40],...
            'String','Provide a name');
       
    edit1 = uicontrol('Parent',dlg,...
            'Style','edit',...
            'Callback', @edit_callback, ...
            'Position',[300 75 100 25]);
        
        
    btn = uicontrol('Parent',dlg,...
            'Position',[425 75 70 25],...
            'String','Done',...
            'Callback',@btn_callback);
        

uiwait(dlg)

    function popup_callback(popup, event)
        % Deduce prefix chosen
        idx = popup.Value;
        popupitems = FirstPrefix;
        choice = char(popupitems(idx,:));
    end

    function edit_callback(edit1, event)      
        % Deduce name given
        name = char(edit1.String);
    end

    function btn_callback(btn, event)      
            % Deduce name given
            popup_callback(popup, event);
            edit_callback(edit1, event);
            NewModelName = strcat(choice, '_', name);
            delete(gcf);
    end
end