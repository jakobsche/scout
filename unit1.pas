unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, PairSplitter,
  ShellCtrls, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    ImageList1: TImageList;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    ShellListView1: TShellListView;
    ShellTreeView1: TShellTreeView;
    StatusBar1: TStatusBar;
    procedure ShellListView1DblClick(Sender: TObject);
    procedure ShellListView1FileAdded(Sender: TObject; Item: TListItem);
    procedure ShellListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ShellListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ShellTreeView1GetImageIndex(Sender: TObject; Node: TTreeNode);
  private

  public
    ListViewPos: TPoint;
    function IsDirectory(Path: string): Boolean; overload;
    function IsDirectory(Item: TListItem): Boolean; overload;
    function IsDirectory(Item: TTreeNode): Boolean; overload;
  end;

var
  Form1: TForm1;

implementation

uses LCLIntf, Patch;

{$R *.lfm}

{ TForm1 }

function TForm1.IsDirectory(Path: string): Boolean;
var
  S: TSearchRec;
begin
  if FindFirst(Path, faDirectory, S) = 0 then Result := S.Attr and faDirectory = faDirectory
  else Result := False;
  FindClose(S)
end;

function TForm1.IsDirectory(Item: TListItem): Boolean;

function GetPath(Item: TListItem): string;
var
  Node: TTreeNode;
begin
  Node := (Item.ListView as TShellListView).ShellTreeView.Selected;
  Result := BuildFileName(Node.GetTextPath, Item.Caption)
end;

begin
  Result := IsDirectory(GetPath(Item))
end;

function TForm1.IsDirectory(Item: TTreeNode): Boolean;
begin
  Result := IsDirectory(Item.GetTextPath)
end;

procedure TForm1.ShellListView1DblClick(Sender: TObject);
var
  TreeNode: TTreeNode;
  Path: string;
begin
  with Sender as TShellListView do
    if Assigned(ShellTreeView) then begin
      Selected := ShellListView1.GetItemAt(ListViewPos.X, ListViewPos.Y);
      if Selected = nil then begin
        {ShowMessage('Keine Selektion');}
        Exit
      end;
      Path := GetPathFromItem(Selected);
      if IsDirectory(Path) then begin
        ShellTreeView.Selected.Expand(False);
        {ShowMessage(Path);}
        TreeNode := ShellTreeView.Selected.FindNode(Selected.Caption);
        if TreeNode = nil then ShowMessage('Knoten fehlt')
        else ShellTreeView.Select(TreeNode)
      end
      else OpenDocument(Path);
    end;
end;

procedure TForm1.ShellListView1FileAdded(Sender: TObject; Item: TListItem);
begin
  if IsDirectory(Item) then Item.ImageIndex := 1
  else Item.ImageIndex := 2;
end;

procedure TForm1.ShellListView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TForm1.ShellListView1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  ListViewPos := Point(X, Y - 28); {Höhe des Tabellenkopfs abziehen}
  StatusBar1.SimpleText := Format('(%d, %d)', [X, Y])
end;

procedure TForm1.ShellTreeView1GetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  if Node = nil then Exit;
  if Node.Parent = nil then begin
    Node.ImageIndex := 1;
    Exit
  end;
  if Node.Parent.Text = 'Volumes' then Node.ImageIndex := 0
  else Node.ImageIndex := 1
end;

end.

