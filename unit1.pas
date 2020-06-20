unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, PairSplitter,
  ShellCtrls, ComCtrls, Menus, ActnList, StdActns;

type

  { TForm1 }

  TForm1 = class(TForm)
    HelpAbout: TAction;
    FileExit1: TFileExit;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    ShowHidden: TAction;
    ActionList1: TActionList;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    ShowHiddenItem: TMenuItem;
    ViewMenu: TMenuItem;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    ShellListView1: TShellListView;
    ShellTreeView1: TShellTreeView;
    StatusBar1: TStatusBar;
    procedure HelpAboutExecute(Sender: TObject);
    procedure ShellListView1Compare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure ShellListView1DblClick(Sender: TObject);
    procedure ShellListView1FileAdded(Sender: TObject; Item: TListItem);
    procedure ShellListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ShellListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ShellTreeView1GetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure ShowHiddenExecute(Sender: TObject);
  private

  public
    ListViewPos: TPoint;
    function IsDirectory(Path: string): Boolean; overload;
    function IsDirectory(Item: TListItem): Boolean; overload;
    function IsDirectory(Item: TTreeNode): Boolean; overload;
    procedure SetListViewPos(X, Y: Integer);
  end;

var
  Form1: TForm1;

implementation

uses LCLIntf, Patch, About;

{$R *.lfm}

{ TForm1 }

function TForm1.IsDirectory(Path: string): Boolean;
var
  S: TSearchRec;
begin
  if FindFirst(Path, faDirectory or faHidden, S) = 0 then
    Result := S.Attr and faDirectory = faDirectory
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

procedure TForm1.ShellListView1Compare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);

procedure CompareCaption;
begin
  if LowerCase(Item1.Caption) < LowerCase(Item2.Caption) then Compare := -1
  else if LowerCase(Item1.Caption) > LowerCase(Item2.Caption) then Compare := 1
  {else Compare := 0}
end;

begin
  if IsDirectory(Item1) and not IsDirectory(Item2) then Compare := -1
  else if not IsDirectory(Item1) and IsDirectory(Item2) then Compare := 1
  else if IsDirectory(Item1) and IsDirectory(Item2) then CompareCaption
  else CompareCaption
end;

procedure TForm1.HelpAboutExecute(Sender: TObject);
begin
  AboutBox.ShowModal
end;

procedure TForm1.ShellListView1FileAdded(Sender: TObject; Item: TListItem);
begin
  if (Sender as TShellListView).ShellTreeView.Selected = nil then Exit;
  if IsDirectory(Item) then
    if (Sender as TShellListView).ShellTreeView.Selected.Text = 'Volumes' then
      Item.ImageIndex := 0
    else
      Item.ImageIndex := 1
  else Item.ImageIndex := 2;
end;

procedure TForm1.ShellListView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  SetListViewPos(X, Y)
end;

procedure TForm1.ShellListView1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  SetListViewPos(X, Y);
end;

procedure TForm1.SetListViewPos(X, Y: Integer);
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

procedure TForm1.ShowHiddenExecute(Sender: TObject);
begin
  with Sender as TAction do begin
    Checked := not Checked;
    if Checked then begin
      ShellTreeView1.ShellListView := nil;
      ShellTreeView1.ObjectTypes := ShellTreeView1.ObjectTypes + [otHidden];
      ShellListView1.ObjectTypes := ShellListView1.ObjectTypes + [otHidden];
      ShellTreeView1.ShellListView := ShellListView1;
    end
    else begin
      ShellTreeView1.ShellListView := nil;
      ShellTreeView1.ObjectTypes := ShellTreeView1.ObjectTypes - [otHidden];
      ShellListView1.ObjectTypes := ShellListView1.ObjectTypes - [otHidden];
      ShellTreeView1.ShellListView := ShellListView1;
    end;
  end;
end;

end.

