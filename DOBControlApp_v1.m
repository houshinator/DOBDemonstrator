function DOBControlApp()
%DOBCONTROLAPP  Interactive DOB Control Explorer
% Run as: DOBControlApp()
% Requires Control System Toolbox, MATLAB R2020b+.
%
% Tab 1 — Responses : Nyquist, step response, disturbance rejection
% Tab 2 — Bode      : closed-loop magnitude & phase, obtained vs target

%% ---- Figure & top-level grid ------------------------------------------
% Use most of the screen
scr = get(0,'ScreenSize');
figW = min(1500, scr(3)-80);
figH = min(920,  scr(4)-80);
fig = uifigure('Name','DOB Control Explorer', ...
               'Position',[40 40 figW figH], ...
               'Color',[0.12 0.13 0.15], ...
               'Resize','on');
G = uigridlayout(fig,[1 2]);
G.ColumnWidth = {320,'1x'}; G.Padding = [8 8 8 8]; G.ColumnSpacing = 10;


%% ---- Left panel (inputs) ----------------------------------------------
LP = uipanel(G,'BackgroundColor',[0.17 0.18 0.21],'BorderType','none', ...
    'Scrollable','on');
LP.Layout.Column = 1;
LG = uigridlayout(LP,[24 1]);
LG.RowHeight = repmat({'fit'},1,24); LG.Padding = [8 8 8 8]; LG.RowSpacing = 3;

H  = @(p,t) uilabel(p,'Text',t,'Interpreter','html', ...
             'FontColor',[0.85 0.90 0.95],'FontSize',11, ...
             'FontWeight','bold','BackgroundColor','none');
Sm = @(p,t) uilabel(p,'Text',t,'Interpreter','html', ...
             'FontColor',[0.50 0.55 0.60],'FontSize',9,'BackgroundColor','none');
acc = [0.35 0.85 0.70];

H(LG,'Plant &nbsp;<i>P</i>(<i>s</i>)');
Sm(LG,'Numerator &nbsp;[<i>b<sub>m</sub></i> &hellip; <i>b</i><sub>0</sub>]');
ui.numP = uitextarea(LG,'Value',{'1'}, ...
    'BackgroundColor',[0.22 0.23 0.26],'FontColor',[0.92 0.95 0.97], ...
    'FontSize',11,'FontName','Courier New');
Sm(LG,'Denominator &nbsp;[1 &nbsp;<i>a</i><sub><i>n</i>&minus;1</sub> &hellip; <i>a</i><sub>0</sub>]');
ui.denP = uitextarea(LG,'Value',{'1  14.4  87.36  290.304  574.6944  688.9882  483.8359  179.5424  26.4241'}, ...
    'BackgroundColor',[0.22 0.23 0.26],'FontColor',[0.92 0.95 0.97], ...
    'FontSize',11,'FontName','Courier New');

H(LG,'Truncation order &nbsp;<i>n</i> &nbsp;(dominant poles retained)');
ui.truncLbl    = valLabel(LG,'<i>n</i> = 4  (of 8)',acc);
ui.truncSlider = makeSlider(LG,[1 7],4,1:7);

H(LG,'DOB &nbsp;<i>Q</i>-filter');
Sm(LG,'<i>&tau;</i> &nbsp;(time constant) &mdash; small <i>&tau;</i> = wide DOB bandwidth');
ui.tauLbl    = valLabel(LG,'<i>&tau;</i> = 0.20',acc);
ui.tauSlider = makeSlider(LG,[0.01 2.0],0.20,[0.01 0.05 0.1 0.2 0.5 1.0 2.0]);
Sm(LG,'<i>&mu;</i> &nbsp;(filter order, auto-clamped &ge; <i>&nu;</i> of <i>P<sub>n</sub></i>)');
ui.muSlider = makeSlider(LG,[1 8],4,1:8);
ui.muLbl    = valLabel(LG,'<i>&mu;</i> = 4',acc);

H(LG,'Outer-loop bandwidth &nbsp;<i>&omega;<sub>c</sub></i>');
ui.wcLbl    = valLabel(LG,'<i>&omega;<sub>c</sub></i> = 0.50 rad s<sup>&minus;1</sup>',acc);
ui.wcSlider = makeSlider(LG,[0.05 5.0],0.5,[0.05 0.1 0.5 1 2 5]);

H(LG,'Diagnostics');
ui.status = uilabel(LG,'Text','&mdash;','Interpreter','html', ...
    'FontColor',[0.85 0.90 0.95],'FontSize',10, ...
    'BackgroundColor',[0.20 0.21 0.24],'WordWrap','on','VerticalAlignment','top');

%% ---- Right panel with tab group ---------------------------------------
RP = uipanel(G,'BackgroundColor',[0.12 0.13 0.15],'BorderType','none');
RP.Layout.Column = 2;

% Nest tab group inside a 1x1 grid so the layout engine sizes it correctly.
% Using Units/Position inside a uipanel does NOT fill it reliably.
RPG = uigridlayout(RP,[1 1]);
RPG.Padding = [0 0 0 0]; RPG.ColumnWidth = {'1x'}; RPG.RowHeight = {'1x'};

tg = uitabgroup(RPG);
tg.Layout.Row = 1; tg.Layout.Column = 1;

tab1 = uitab(tg,'Title',' Responses ','BackgroundColor',[0.12 0.13 0.15]);
tab2 = uitab(tg,'Title',' Bode '     ,'BackgroundColor',[0.12 0.13 0.15]);

%% ---- Tab 1: response axes ---------------------------------------------
bg = [0.16 0.17 0.20]; fg = [0.78 0.83 0.88];

RG1 = uigridlayout(tab1,[3 1]);
RG1.RowHeight = {'1x','1x','1x'}; RG1.Padding = [6 6 6 6]; RG1.RowSpacing = 10;

ui.axNyq  = mkAx(RG1,1,bg,fg, ...
    'Nyquist diagram $-$ $P(s)$ and $P_n(s)$', ...
    '$\mathrm{Re}[P(j\omega)]$','$\mathrm{Im}[P(j\omega)]$');
ui.axStep = mkAx(RG1,2,bg,fg, ...
    'Step response: $r \to y$', ...
    'Time $t$ (s)','$y(t)$');
ui.axDist = mkAx(RG1,3,bg,fg, ...
    'Disturbance rejection: $d \to y$ (step input disturbance)', ...
    'Time $t$ (s)','$y(t)$');

%% ---- Tab 2: Bode axes -------------------------------------------------
RG2 = uigridlayout(tab2,[2 1]);
RG2.RowHeight = {'1x','1x'}; RG2.Padding = [6 6 6 6]; RG2.RowSpacing = 6;

ui.axBodeMag = mkAx(RG2,1,bg,fg, ...
    'Bode magnitude: closed-loop $r \to y$  (obtained vs target)', ...
    '$\omega$ (rad s$^{-1}$)','Magnitude (dB)');
ui.axBodePh  = mkAx(RG2,2,bg,fg, ...
    'Bode phase: closed-loop $r \to y$  (obtained vs target)', ...
    '$\omega$ (rad s$^{-1}$)','Phase (deg)');

% Log frequency axis
set(ui.axBodeMag,'XScale','log');
set(ui.axBodePh, 'XScale','log');

%% ---- Callbacks --------------------------------------------------------
ui.truncSlider.ValueChangingFcn = @(s,e) ...
    set(ui.truncLbl,'Text',sprintf('<i>n</i> = %d', round(e.Value)));
ui.tauSlider.ValueChangingFcn   = @(s,e) ...
    set(ui.tauLbl,'Text',  sprintf('<i>&tau;</i> = %.3g', e.Value));
ui.muSlider.ValueChangingFcn    = @(s,e) ...
    set(ui.muLbl,'Text',   sprintf('<i>&mu;</i> = %d', round(e.Value)));
ui.wcSlider.ValueChangingFcn    = @(s,e) ...
    set(ui.wcLbl,'Text',   sprintf('<i>&omega;<sub>c</sub></i> = %.3g rad s<sup>&minus;1</sup>', e.Value));

for f = {'truncSlider','tauSlider','muSlider','wcSlider','numP','denP'}
    ui.(f{1}).ValueChangedFcn = @(~,~) recompute(ui);
end

recompute(ui);
end

%% =========================================================================
function recompute(ui)
C_ = struct('P', [0.30 0.65 0.92],'Pn',[0.95 0.72 0.25], ...
            'nom',[0.45 0.88 0.55],'dob',[0.92 0.38 0.38], ...
            'bg', [0.16 0.17 0.20],'fg', [0.78 0.83 0.88]);
try

%% 1. Parse P(s) ----------------------------------------------------------
numP = str2num(strjoin(ui.numP.Value)); %#ok<ST2NM>
denP = str2num(strjoin(ui.denP.Value)); %#ok<ST2NM>
if isempty(numP)||isempty(denP)
    setStatus(ui,'&#10060; Cannot parse num/den.',1); return
end
denP  = denP/denP(1);
nFull = numel(denP)-1;
nuP   = nFull-(numel(numP)-1);
if nuP<1, setStatus(ui,'&#10060; P(s) must be strictly proper.',1); return; end
P_tf  = tf(numP,denP);

%% 2. Galerkin truncation → poles-only Pn --------------------------------
nMax = max(1,nFull-1);
ui.truncSlider.Limits = [1 nMax];
nTrunc  = max(1,min(round(ui.truncSlider.Value),nMax));
ui.truncLbl.Text = sprintf('<i>n</i> = %d &nbsp;(of %d)',nTrunc,nFull);

polesP  = pole(P_tf);
[~,ord] = sort(real(polesP),'descend');
idx     = safeIdx(ord,polesP,nTrunc);
retPoles = polesP(idx);
nuPn     = numel(retPoles);

charDen = real(poly(retPoles));
dcP     = abs(real(evalfr(P_tf,0)));
Pn_tf   = tf(dcP*charDen(end),charDen);

%% 3. Q-filter  Q(s) = 1/(τs+1)^μ ----------------------------------------
tau = ui.tauSlider.Value;
mu  = max(round(ui.muSlider.Value),nuPn);
ui.muSlider.Value = mu;
ui.muLbl.Text     = sprintf('<i>&mu;</i> = %d',mu);
ui.tauLbl.Text    = sprintf('<i>&tau;</i> = %.3g',tau);

Q_tf = tf(1,1);
for k=1:mu, Q_tf = Q_tf*tf(1,[tau 1]); end

%% 4. Outer-loop C(s) via pidtune on Pn ----------------------------------
wc = ui.wcSlider.Value;
ui.wcLbl.Text = sprintf('<i>&omega;<sub>c</sub></i> = %.3g rad s<sup>&minus;1</sup>',wc);
try   C_tf = pidtune(Pn_tf,'PI',wc);
catch, C_tf = pidtune(Pn_tf,'P',wc); end
nomCL = minreal(feedback(Pn_tf*C_tf,1),1e-3,false);

%% 5. DOB closed loop via connect() --------------------------------------
QPn_tf = minreal(Q_tf/Pn_tf,1e-2,false);

Pb  = tf(P_tf);   Pb.InputName  = 'up';    Pb.OutputName  = 'y';
QAb = tf(Q_tf);   QAb.InputName = 'u';     QAb.OutputName = 'yp';
Cb  = tf(C_tf);   Cb.InputName  = 'e';     Cb.OutputName  = 'ubar';
Fb  = tf(QPn_tf); Fb.InputName  = 'y';     Fb.OutputName  = 'uhatn';

s_up  = sumblk('up    =  u + d');
s_err = sumblk('e     =  r - y');
s_dob = sumblk('u     =  ubar + yp - uhatn');

T_cl = connect(Pb,QAb,Cb,Fb,s_up,s_err,s_dob,{'r','d'},{'y'});
T_r  = T_cl(1,1);
T_d  = T_cl(1,2);

dcr = abs(real(evalfr(T_r,0)));
if dcr>1e-10, T_r = T_r/dcr; end

stabR = isstable(T_r);
stabD = isstable(T_d);

%% 6. Status --------------------------------------------------------------
discPoles = polesP(setdiff(1:nFull,idx));
zpP = zero(P_tf); minPh = isempty(zpP)||all(real(zpP)<0);
[Gm,Pm] = margin(Pn_tf*C_tf);
msg = sprintf([ ...
    '<i>P</i>(<i>s</i>) order %d, &nbsp;<i>&nu;</i> = %d, &nbsp;%s<br>' ...
    '<i>P<sub>n</sub></i> order %d &mdash; retained: %s<br>' ...
    '&nbsp;&nbsp;discarded: %s<br>' ...
    'Loop margins: GM = %.1f dB, &nbsp;PM = %.0f&deg;<br>' ...
    '<i>T<sub>r</sub></i>: %s &nbsp;&nbsp;' ...
    '<i>T<sub>d</sub></i>: %s'], ...
    nFull,nuP,ternary(minPh,'min-phase','NON-min-phase'),nuPn, ...
    fmtPoles(retPoles),fmtPoles(discPoles), ...
    20*log10(Gm),Pm, ...
    ternary(stabR,'&#10003; stable','&#10007; UNSTABLE'), ...
    ternary(stabD,'&#10003; stable','&#10007; UNSTABLE'));
setStatus(ui,msg,~stabR||~stabD);

%% 7. Frequency vector (shared across all plots) -------------------------
polesMag = abs([polesP; 1/tau]);
wLo = min(polesMag)*0.05;
wHi = max(polesMag)*20;
wv  = logspace(log10(wLo),log10(wHi),2000);
tEnd = max(30,8/wc); tv = linspace(0,tEnd,2000);

%% 8. TAB 1 — Nyquist ----------------------------------------------------
ax = ui.axNyq; cla(ax);
nyqPlot(ax,P_tf, C_.P,  '$P(j\omega)$');
nyqPlot(ax,Pn_tf,C_.Pn, '$P_n(j\omega)$');
xline(ax,-1,'Color',[0.85 0.25 0.25],'LineStyle','--','LineWidth',1.2);
plot(ax,-1,0,'x','Color',[0.85 0.25 0.25],'MarkerSize',10,'LineWidth',2);
lg=legend(ax,'Location','best'); lg.Interpreter='latex';
lg.TextColor=C_.fg; lg.Color=C_.bg;
axis(ax,'equal'); grid(ax,'on');

%% 9. TAB 1 — Step response ----------------------------------------------
ax = ui.axStep; cla(ax);
plot(ax,tv,step(nomCL,tv),'--','Color',C_.nom,'LineWidth',2.0, ...
    'DisplayName','$P_n + C$ (target)');
if stabR
    plot(ax,tv,step(T_r,tv),'-','Color',C_.dob,'LineWidth',1.8, ...
        'DisplayName','$P + $ DOB (obtained)');
else
    text(ax,.5,.5,'$r\to y$ UNSTABLE','Interpreter','latex', ...
        'Units','normalized','HorizontalAlignment','center', ...
        'Color',[0.9 0.3 0.3],'FontSize',12);
end
lg=legend(ax,'Location','best'); lg.Interpreter='latex';
lg.TextColor=C_.fg; lg.Color=C_.bg; grid(ax,'on');

%% 10. TAB 1 — Disturbance rejection -------------------------------------
ax = ui.axDist; cla(ax);
if stabD
    plot(ax,tv,step(T_d,tv),'-','Color',C_.P,'LineWidth',1.8, ...
        'DisplayName','$y(t)$ under step $d$');
    yline(ax,0,'--','Color',C_.fg,'LineWidth',0.9,'Alpha',0.5);
    lg=legend(ax,'Location','best'); lg.Interpreter='latex';
    lg.TextColor=C_.fg; lg.Color=C_.bg;
else
    text(ax,.5,.5,'$d\to y$ UNSTABLE','Interpreter','latex', ...
        'Units','normalized','HorizontalAlignment','center', ...
        'Color',[0.9 0.3 0.3],'FontSize',12);
end
grid(ax,'on');

%% 11. TAB 2 — Bode magnitude --------------------------------------------
ax = ui.axBodeMag; cla(ax);
ax.XScale = 'log';

% Target: nominal closed loop
H_nom = squeeze(freqresp(nomCL,wv));
mag_nom = 20*log10(abs(H_nom)+eps);
plot(ax,wv,mag_nom,'--','Color',C_.nom,'LineWidth',2.0, ...
    'DisplayName','$P_n + C$ (target)');

if stabR
    H_r = squeeze(freqresp(T_r,wv));
    mag_r = 20*log10(abs(H_r)+eps);
    plot(ax,wv,mag_r,'-','Color',C_.dob,'LineWidth',1.8, ...
        'DisplayName','$P + $ DOB (obtained)');
end

% -3 dB line and ωc marker
yline(ax,-3,':','Color',C_.fg,'LineWidth',0.9,'Alpha',0.5,'Label','-3 dB', ...
    'LabelHorizontalAlignment','left','Interpreter','none');
xline(ax,wc,'--','Color',[0.90 0.75 0.30],'LineWidth',1.0, ...
    'Label','\omega_c','LabelVerticalAlignment','bottom','Interpreter','tex');

lg=legend(ax,'Location','southwest'); lg.Interpreter='latex';
lg.TextColor=C_.fg; lg.Color=C_.bg; grid(ax,'on');

%% 12. TAB 2 — Bode phase ------------------------------------------------
ax = ui.axBodePh; cla(ax);
ax.XScale = 'log';

ph_nom = rad2deg(unwrap(angle(H_nom)));
plot(ax,wv,ph_nom,'--','Color',C_.nom,'LineWidth',2.0, ...
    'DisplayName','$P_n + C$ (target)');

if stabR
    ph_r = rad2deg(unwrap(angle(H_r)));
    plot(ax,wv,ph_r,'-','Color',C_.dob,'LineWidth',1.8, ...
        'DisplayName','$P + $ DOB (obtained)');
end

% -180° line
yline(ax,-180,':','Color',C_.fg,'LineWidth',0.9,'Alpha',0.5,'Label','-180°', ...
    'LabelHorizontalAlignment','left','Interpreter','none');
xline(ax,wc,'--','Color',[0.90 0.75 0.30],'LineWidth',1.0, ...
    'Label','\omega_c','LabelVerticalAlignment','bottom','Interpreter','tex');

lg=legend(ax,'Location','southwest'); lg.Interpreter='latex';
lg.TextColor=C_.fg; lg.Color=C_.bg; grid(ax,'on');

catch ME
    setStatus(ui,['&#10060; ' ME.message],1);
end
end

%% ---- Helpers -----------------------------------------------------------
function idx = safeIdx(ord,poles,n)
idx=[]; kept=0; i=0;
while kept<n && i<numel(ord)
    i=i+1;
    if ismember(ord(i),idx), continue; end
    p=poles(ord(i));
    if abs(imag(p))>1e-8
        [~,j]=min(abs(poles-conj(p)));
        if kept+2<=n, idx(end+1)=ord(i); idx(end+1)=j; kept=kept+2; end
    else
        idx(end+1)=ord(i); kept=kept+1;
    end
end
end

function nyqPlot(ax,sys,clr,lbl)
w=logspace(-3,3,3000); H=squeeze(freqresp(sys,w));
plot(ax,real(H), imag(H),'-','Color',clr,'LineWidth',1.6,'DisplayName',lbl);
plot(ax,real(H),-imag(H),':','Color',clr,'LineWidth',0.8,'HandleVisibility','off');
end

function s = fmtPoles(p)
if isempty(p), s='(none)'; return; end
s=strjoin(arrayfun(@(x)sprintf('%.3g%+.3g<i>j</i>',real(x),imag(x)),p,'uni',0),'&nbsp;');
end

function lbl = valLabel(parent,txt,clr)
lbl=uilabel(parent,'Text',txt,'Interpreter','html', ...
    'FontColor',clr,'FontSize',13,'FontWeight','bold', ...
    'BackgroundColor','none','HorizontalAlignment','center');
end

function sl = makeSlider(parent,lims,val,ticks)
sl=uislider(parent,'Limits',lims,'Value',val,'FontColor',[0.70 0.75 0.80]);
sl.MajorTicks=ticks;
sl.MajorTickLabels=arrayfun(@(x)sprintf('%g',x),ticks,'uni',0);
end

function ax = mkAx(parent,row,bg,fg,ttl,xl,yl)
ax=uiaxes(parent,'BackgroundColor',bg,'XColor',fg,'YColor',fg, ...
    'GridColor',fg,'GridAlpha',0.15,'FontSize',10);
ax.Layout.Row=row; ax.Layout.Column=1;
title(ax,ttl,'Color',fg,'FontSize',11,'FontWeight','bold','Interpreter','latex');
xlabel(ax,xl,'Color',fg,'Interpreter','latex');
ylabel(ax,yl,'Color',fg,'Interpreter','latex');
hold(ax,'on');
end

function setStatus(ui,msg,isErr)
ui.status.Text=msg; ui.status.Interpreter='html';
ui.status.FontColor=ternary(isErr,[0.95 0.35 0.35],[0.55 0.90 0.60]);
end

function out=ternary(c,a,b)
if c, out=a; else, out=b; end
end