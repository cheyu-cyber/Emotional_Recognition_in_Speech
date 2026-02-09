function varargout = AudioAnalysis(varargin)
% AUDIOANALYSIS MATLAB code for AudioAnalysis.fig
%      AUDIOANALYSIS, by itself, creates a new AUDIOANALYSIS or raises the existing
%      singleton*.
%
%      H = AUDIOANALYSIS returns the handle to a new AUDIOANALYSIS or the handle to
%      the existing singleton*.
%
%      AUDIOANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUDIOANALYSIS.M with the given input arguments.
%
%      AUDIOANALYSIS('Property','Value',...) creates a new AUDIOANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AudioAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AudioAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AudioAnalysis

% Last Modified by GUIDE v2.5 29-Dec-2019 13:03:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AudioAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @AudioAnalysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before AudioAnalysis is made visible.
function AudioAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AudioAnalysis (see VARARGIN)

% Choose default command line output for AudioAnalysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AudioAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AudioAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
