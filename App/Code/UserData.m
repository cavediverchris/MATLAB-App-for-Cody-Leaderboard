classdef UserData<handle
    %USERDATA a class to contain player data and methods
    %   Detailed explanation goes here
    
    properties
        UserID
        url
        name
        score
        badges
    end % properties
    
    methods
        function obj = UserData(id)
            %USERDATA Construct an instance of this class
            %   Detailed explanation goes here
            if nargin>0 % zero inputs will create an empty class.
                setUID(obj,id);
                geturl(obj);
                getPlayerdata(obj)
            end %if
        end %function
        
        function obj=setUID(obj,id)
            obj.UserID=id;
        end%function
        
        function obj = geturl(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.url = sprintf('https://www.mathworks.com/matlabcentral/cody/players/%d',obj.UserID);
        end %function
        
        function obj = getPlayerdata(obj)
            target = '<a href="/matlabcentral/cody/players/.*?" title="Score: (\d+), Badges: (\d+)">(.*?)</a>';
            tk = regexp(webread(obj.url),target,'tokens','once');
            obj.name = tk{3};
            obj.score = str2double(tk{1});
            obj.badges = str2double(tk{2});
        end %function
    end %methods
end %classdef

