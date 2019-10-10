function namingConvention
%NAMINGCONVENTION Summary of this function goes here
%   Detailed explanation goes here

rec = ModelAdvisor.Check('mathworks.example.configManagement');
rec.Title = 'Confirming that model names match naming convention';
rec.TitleTips = 'Example new style callback (recommended check style)';
rec.setCallbackFcn(@modelVersionChecksumCallbackUsingFT,'None','StyleOne');
rec.CallbackContext = 'PostCompile';
rec.Group = 'Recommended MBSE Checks Group';

% add 'Explore Result' button
rec.ListViewVisible = true;

% set fix operation
myAction0 = ModelAdvisor.Action;
myAction0.setCallbackFcn(@sampleActionCB0);
myAction0.Name='Make block names appear below blocks';
myAction0.Description='Click the button to place block names below blocks';
rec.setAction(myAction0);


% 
mdladvRoot = ModelAdvisor.Root;
mdladvRoot.FactoryGroup = 'MBSE Checks';
mdladvRoot.register(rec);



end

