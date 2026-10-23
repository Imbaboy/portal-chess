function PortalChess
% PORTALCHESS - Experimental MATLAB prototype for the proposed Portal Chess rules.
% Status: unverified draft. Review and test before relying on it.
%
% Implemented (draft): 8x8 board, standard piece movement, legal-move filtering,
% optional teleportation to an empty square, pawn teleport destination restriction,
% portal relocation every 5 plies, automatic queen promotion, and basic
% check/checkmate/stalemate detection. This code has NOT been validated in MATLAB.
%
% Pawn teleport restriction: White pawns may teleport only to ranks 2-4;
% Black pawns may teleport only to ranks 5-7. Board rows are indexed from the
% top (row 1 = rank 8; row 8 = rank 1).
%
% Not implemented in this prototype: castling, en passant, repetition draws,
% fifty-move rule, move notation, AI, network play, and selectable promotion.
%
% Declaration of OpenAI use:
% ChatGPT assisted with drafting this prototype. It has not been independently
% validated and must be tested and reviewed by its users. OpenAI does not
% endorse or verify this project.

    B = initialBoard();
    side = 'w';                 % White moves first
    ply = 0;
    portal = newPortals(B);
    selected = [];
    legalDests = [];
    gameOver = false;

    fig = figure('Name','Portal Chess (experimental prototype)', ...
        'NumberTitle','off','MenuBar','none','Color',[0.94 0.94 0.94], ...
        'Position',[100 80 760 690],'Resize','off');
    ax = axes('Parent',fig,'Position',[0.06 0.13 0.72 0.80]);
    axis(ax,[0.5 8.5 0.5 8.5]); axis(ax,'equal'); axis(ax,'ij');
    set(ax,'XTick',1:8,'YTick',1:8,'XTickLabel',{'a','b','c','d','e','f','g','h'}, ...
        'YTickLabel',{'8','7','6','5','4','3','2','1'},'TickLength',[0 0], ...
        'FontSize',11,'Box','on','YDir','reverse');
    hold(ax,'on');
    status = uicontrol(fig,'Style','text','Units','normalized', ...
        'Position',[0.80 0.75 0.18 0.15],'String','White to move', ...
        'FontSize',12,'HorizontalAlignment','left','BackgroundColor',get(fig,'Color'));
    info = uicontrol(fig,'Style','text','Units','normalized', ...
        'Position',[0.80 0.47 0.18 0.24],'String','', ...
        'FontSize',10,'HorizontalAlignment','left','BackgroundColor',get(fig,'Color'));
    newBtn = uicontrol(fig,'Style','pushbutton','Units','normalized', ...
        'Position',[0.80 0.35 0.17 0.06],'String','New Game','Callback',@newGame);
    uicontrol(fig,'Style','text','Units','normalized','Position',[0.80 0.12 0.18 0.18], ...
        'String',sprintf(['Click a piece, then its destination.\\n\\nBlue/cyan rings = portals.\\n' ...
        'If a piece lands on a portal, choose whether to teleport.']), ...
        'FontSize',9,'HorizontalAlignment','left','BackgroundColor',get(fig,'Color'));
    renderBoard();

    function newGame(~,~)
        B = initialBoard(); side = 'w'; ply = 0; portal = newPortals(B);
        selected = []; legalDests = []; gameOver = false;
        renderBoard();
    end

    function renderBoard()
        cla(ax); hold(ax,'on');
        for rr=1:8
            for cc=1:8
                if mod(rr+cc,2)==0, fc=[0.92 0.88 0.78]; else, fc=[0.42 0.52 0.42]; end
                rectangle(ax,'Position',[cc-0.5 rr-0.5 1 1],'FaceColor',fc,'EdgeColor',[0.25 0.25 0.25]);
                if ~isempty(selected) && isequal([rr cc],selected)
                    rectangle(ax,'Position',[cc-0.48 rr-0.48 0.96 0.96],'EdgeColor',[1 0.65 0],'LineWidth',3);
                end
                if ~isempty(legalDests) && any(all(legalDests==[rr cc],2))
                    plot(ax,cc,rr,'o','MarkerSize',12,'LineWidth',2,'Color',[1 0.2 0.15]);
                end
                if any(all(portal==[rr cc],2))
                    rectangle(ax,'Position',[cc-0.34 rr-0.34 0.68 0.68], ...
                        'Curvature',[1 1],'EdgeColor',[0.1 0.85 1],'LineWidth',3);
                end
                p=B(rr,cc);
                if p~='.'
                    [sym,~]=pieceSymbol(p);
                    if isupper(p), col=[0.98 0.98 0.94]; else, col=[0.12 0.12 0.15]; end
                    text(ax,cc,rr,sym,'HorizontalAlignment','center','VerticalAlignment','middle', ...
                        'FontSize',29,'FontWeight','bold','Color',col, ...
                        'ButtonDownFcn',@(src,evt) squareClick(rr,cc));
                end
                % Invisible clickable patch makes empty squares selectable.
                patch(ax,[cc-.5 cc+.5 cc+.5 cc-.5],[rr-.5 rr-.5 rr+.5 rr+.5], ...
                    'w','FaceAlpha',0,'EdgeColor','none','HitTest','off', ...
                    'ButtonDownFcn',@(src,evt) squareClick(rr,cc));
            end
        end
        title(ax,'Portal Chess','FontSize',15);
        if gameOver
            status.String='Game over';
        else
            if side=='w', who='White'; else, who='Black'; end
            status.String=sprintf('%s to move',who);
        end
        info.String=sprintf('Plies: %d\\nRelocation in: %d\\nPortal A: %s\\nPortal B: %s', ...
            ply,5-mod(ply,5),squareName(portal(1,:)),squareName(portal(2,:)));
        drawnow;
    end

    function squareClick(r,c)
        if gameOver, return; end
        if ~isempty(selected) && any(all(legalDests==[r c],2))
            makeMove(selected,[r c]); return;
        end
        p=B(r,c);
        if p~='.' && belongsTo(p,side)
            selected=[r c];
            moves=legalMovesFrom(B,selected,side,portal);
            legalDests=zeros(0,2);
            for k=1:size(moves,1)
                if ~any(all(legalDests==moves(k,:),2)), legalDests(end+1,:)=moves(k,:); end %#ok<AGROW>
            end
        else
            selected=[]; legalDests=[];
        end
        renderBoard();
    end

    function makeMove(from,to)
        moving=B(from(1),from(2));
        candidate=applyMove(B,from,to);
        isPortal=any(all(portal==to,2));
        if isPortal
            choice=questdlg('This move lands on a portal. What would you like to do?', ...
                'Portal activated','Remain','Teleport','Remain');
            if isempty(choice), selected=[]; legalDests=[]; renderBoard(); return; end
            if strcmp(choice,'Teleport')
                empties=zeros(0,2);
                for rr=1:8
                    for cc=1:8
                        if candidate(rr,cc)=='.' && pawnTeleportAllowed(moving,[rr cc])
                            test=candidate; test(rr,cc)=moving; test(to(1),to(2))='.';
                            if ~isInCheck(test,side), empties(end+1,:)=[rr cc]; end %#ok<AGROW>
                        end
                    end
                end
                if isempty(empties)
                    warndlg('No legal empty teleport destination preserves king safety. The piece will remain on the portal.','Portal Chess');
                else
                    [idx,ok]=listdlg('PromptString','Choose an empty teleport destination:', ...
                        'SelectionMode','single','ListString',cellstr(arrayfun(@(k)squareName(empties(k,:)), ...
                        1:size(empties,1),'UniformOutput',false)),'ListSize',[220 300]);
                    if ok
                        dest=empties(idx,:);
                        candidate(to(1),to(2))='.';
                        candidate(dest(1),dest(2))=moving;
                    end
                end
            end
        end
        if isInCheck(candidate,side)
            errordlg('Illegal move: your king would be in check.','Portal Chess');
            selected=[]; legalDests=[]; renderBoard(); return;
        end
        B=candidate;
        % Automatic queen promotion (the prototype does not offer a promotion menu).
        if moving=='P' && to(1)==1, B(to(1),to(2))='Q'; end
        if moving=='p' && to(1)==8, B(to(1),to(2))='q'; end
        ply=ply+1;
        side=opponent(side);
        if mod(ply,5)==0
            portal=newPortals(B);
        end
        selected=[]; legalDests=[];
        renderBoard();
        if isInCheck(B,side)
            msg=sprintf('%s is in check.',sideName(side));
            status.String=msg;
        end
        allm=allLegalMoves(B,side,portal);
        if isempty(allm)
            gameOver=true;
            renderBoard();
            if isInCheck(B,side)
                msgbox(sprintf('Checkmate! %s wins.',sideName(opponent(side))),'Portal Chess');
            else
                msgbox('Stalemate! The game is a draw.','Portal Chess');
            end
        end
    end

    function moves=legalMovesFrom(board,from,color,portals)
        pseudo=pseudoMoves(board,from,color);
        moves=zeros(0,2);
        piece=board(from(1),from(2));
        for ii=1:size(pseudo,1)
            to2=pseudo(ii,:);
            b2=applyMove(board,from,to2);
            % Remaining on the portal must be legal; teleport choices are separately checked on landing.
            if ~isInCheck(b2,color)
                moves(end+1,:)=to2; %#ok<AGROW>
            elseif any(all(portals==to2,2))
                % Allow landing as a portal transit if at least one empty teleport destination saves the king.
                if hasLegalTeleport(b2,to2,piece,color)
                    moves(end+1,:)=to2; %#ok<AGROW>
                end
            end
        end
    end

    function yes=hasLegalTeleport(board,portalSquare,piece,color)
        yes=false;
        for r2=1:8
            for c2=1:8
                if board(r2,c2)=='.' && pawnTeleportAllowed(piece,[r2 c2])
                    test=board; test(portalSquare(1),portalSquare(2))='.'; test(r2,c2)=piece;
                    if ~isInCheck(test,color), yes=true; return; end
                end
            end
        end
    end

    function allm=allLegalMoves(board,color,portals)
        allm=zeros(0,4);
        for rr=1:8
            for cc=1:8
                if board(rr,cc)~='.' && belongsTo(board(rr,cc),color)
                    m=legalMovesFrom(board,[rr cc],color,portals);
                    for kk=1:size(m,1)
                        allm(end+1,:)=[rr cc m(kk,:)]; %#ok<AGROW>
                    end
                end
            end
        end
    end
end

function B=initialBoard()
B=repmat('.',8,8);
B(1,:)='rnbqkbnr'; B(2,:)='pppppppp';
B(7,:)='PPPPPPPP'; B(8,:)='RNBQKBNR';
end

function portals=newPortals(B)
% Portal 1 is in rows 1:4; portal 2 is in rows 5:8.
while true
    a=[randi(4),randi(8)];
    b=[randi(4)+4,randi(8)];
    if B(a(1),a(2))=='.' && B(b(1),b(2))=='.' && ~isequal(a,b)
        portals=[a;b]; return;
    end
end
end

function moves=pseudoMoves(B,from,color)
r=from(1); c=from(2); p=B(r,c); moves=zeros(0,2);
if p=='.', return; end
kind=lower(p);
if kind=='p'
    dir=-1; start=7; enemy='b';
    if color=='b', dir=1; start=2; enemy='w'; end
    nr=r+dir;
    if nr>=1 && nr<=8 && B(nr,c)=='.'
        moves(end+1,:)=[nr c];
        if r==start && B(r+2*dir,c)=='.', moves(end+1,:)=[r+2*dir c]; end
    end
    for dc=[-1 1]
        nc=c+dc; nr=r+dir;
        if nr>=1 && nr<=8 && nc>=1 && nc<=8 && B(nr,nc)~='.' && belongsTo(B(nr,nc),enemy)
            moves(end+1,:)=[nr nc];
        end
    end
    return;
end
if kind=='n'
    offsets=[-2 -1;-2 1;-1 -2;-1 2;1 -2;1 2;2 -1;2 1];
    for k=1:size(offsets,1), addStep(r+offsets(k,1),c+offsets(k,2)); end
    return;
end
dirs=[];
if any(kind==['k','q']), dirs=[dirs;-1 -1;-1 0;-1 1;0 -1;0 1;1 -1;1 0;1 1]; end
if any(kind==['r','q']), dirs=[dirs;-1 0;1 0;0 -1;0 1]; end
if any(kind==['b','q']), dirs=[dirs;-1 -1;-1 1;1 -1;1 1]; end
% Remove duplicate directions (queen combines direction sets).
dirs=unique(dirs,'rows','stable');
for k=1:size(dirs,1)
    dr=dirs(k,1); dc=dirs(k,2); nr=r+dr; nc=c+dc;
    while nr>=1 && nr<=8 && nc>=1 && nc<=8
        target=B(nr,nc);
        if target=='.'
            moves(end+1,:)=[nr nc]; %#ok<AGROW>
        elseif belongsTo(target,opponent(color))
            moves(end+1,:)=[nr nc]; %#ok<AGROW>
            break;
        else
            break;
        end
        if kind=='k', break; end
        nr=nr+dr; nc=nc+dc;
    end
end

    function addStep(rr,cc)
        if rr<1 || rr>8 || cc<1 || cc>8, return; end
        if B(rr,cc)=='.' || belongsTo(B(rr,cc),opponent(color))
            moves(end+1,:)=[rr cc]; %#ok<AGROW>
        end
    end
end

function B2=applyMove(B,from,to)
B2=B; piece=B(from(1),from(2));
B2(from(1),from(2))='.';
B2(to(1),to(2))=piece;
end

function yes=isInCheck(B,color)
yes=false;
if color=='w', king='K'; else, king='k'; end
[r,c]=find(B==king,1);
if isempty(r), yes=true; return; end
enemy=opponent(color);
for rr=1:8
    for cc=1:8
        p=B(rr,cc);
        if p~='.' && belongsTo(p,enemy)
            if attacksSquare(B,[rr cc],[r c],enemy), yes=true; return; end
        end
    end
end
end

function yes=attacksSquare(B,from,target,color)
r=from(1); c=from(2); tr=target(1); tc=target(2); p=lower(B(r,c));
dr=tr-r; dc=tc-c; yes=false;
if p=='p'
    if color=='w', yes=(dr==-1 && abs(dc)==1); else, yes=(dr==1 && abs(dc)==1); end
elseif p=='n'
    yes=(abs(dr)==2 && abs(dc)==1)||(abs(dr)==1 && abs(dc)==2);
elseif p=='k'
    yes=max(abs(dr),abs(dc))==1;
elseif p=='r' || p=='b' || p=='q'
    if p=='r', aligned=(dr==0 || dc==0);
    elseif p=='b', aligned=(abs(dr)==abs(dc));
    else, aligned=(dr==0 || dc==0 || abs(dr)==abs(dc)); end
    if aligned && ~(dr==0 && dc==0)
        sr=sign(dr); sc=sign(dc); rr=r+sr; cc=c+sc; clearPath=true;
        while rr~=tr || cc~=tc
            if B(rr,cc)~='.', clearPath=false; break; end
            rr=rr+sr; cc=cc+sc;
        end
        yes=clearPath;
    end
end
end

function yes=pawnTeleportAllowed(piece,dest)
% Enforce the proposed Portal Chess pawn teleport restriction.
% MATLAB board rows map to chess ranks as rank = 9 - row.
yes=true;
if upper(piece)=='P'
    rank=9-dest(1);
    if piece=='P'       % White pawn: ranks 2, 3, or 4
        yes=ismember(rank,[2 3 4]);
    elseif piece=='p'   % Black pawn: ranks 5, 6, or 7
        yes=ismember(rank,[5 6 7]);
    end
end
end

function yes=belongsTo(piece,color)
if color=='w', yes=isstrprop(piece,'upper'); else, yes=isstrprop(piece,'lower'); end
end

function color=opponent(color)
if color=='w', color='b'; else, color='w'; end
end

function s=sideName(color)
if color=='w', s='White'; else, s='Black'; end
end

function s=squareName(sq)
files='abcdefgh'; ranks='87654321';
s=[files(sq(2)) ranks(sq(1))];
end

function [sym,desc]=pieceSymbol(p)
desc='';
switch p
    case {'K','k'}, sym='♚';
    case {'Q','q'}, sym='♛';
    case {'R','r'}, sym='♜';
    case {'B','b'}, sym='♝';
    case {'N','n'}, sym='♞';
    case {'P','p'}, sym='♟';
    otherwise, sym=' ';
end
end
