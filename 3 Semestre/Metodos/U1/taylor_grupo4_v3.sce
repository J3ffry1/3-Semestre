// ============================================================
//  PRÁCTICA 1 - POLINOMIO DE TAYLOR  |  GRUPO 4
//  f(x) = e^(sen(sqrt(x+1)))   en  x = 10
//  Asignatura : Métodos Numéricos  |  NRC: 29528
//  Docente    : Ing. Rodrigo Bastidas
//  Período    : Marzo-Agosto 2026
// ============================================================

clc; clear; funcprot(0);

// ============================================================
// FUNCIONES
// ============================================================

function y = mif(x)
    y = exp(sin(sqrt(x + 1)));
endfunction

function d = mider(x, n)
    h = 1e-5;
    if n == 0 then d = mif(x); end
    if n == 1 then d = (mif(x+h) - mif(x-h)) / (2*h); end
    if n == 2 then d = (mif(x+h) - 2*mif(x) + mif(x-h)) / h^2; end
    if n == 3 then d = (mif(x+2*h) - 2*mif(x+h) + 2*mif(x-h) - mif(x-2*h)) / (2*h^3); end
endfunction

function fact = mifact(n)
    fact = 1; k = 1;
    while k <= n
        fact = fact * k; k = k + 1;
    end
endfunction

function [T, P] = mitaylor(a, xv)
    T = zeros(1,4); P = zeros(1,4); acum = 0; k = 0;
    while k <= 3
        t = (mider(a,k) / mifact(k)) * (xv - a)^k;
        T(k+1) = t; acum = acum + t; P(k+1) = acum;
        k = k + 1;
    end
endfunction

// ============================================================
// GUI  (700 x 620)
// ============================================================

FW = 700; FH = 620;

hf = figure('position',   [80 50 FW FH], ...
            'background',  [0.13 0.14 0.18], ...
            'name',        'Taylor Grupo 4 - NRC 29528', ...
            'resize',      'off');

// --- HEADER ---
uicontrol('parent',hf,'style','frame','position',[0 FH-55 FW 55],'backgroundcolor',[0.08 0.09 0.12]);
uicontrol('parent',hf,'style','text','position',[0 FH-32 FW 22], ...
          'string','POLINOMIO DE TAYLOR  |  f(x) = e^(sen(sqrt(x+1)))  |  Grupo 4  |  NRC 29528', ...
          'fontsize',11,'fontweight','bold','foregroundcolor',[0.35 0.80 0.50], ...
          'backgroundcolor',[0.08 0.09 0.12],'horizontalalignment','center');
uicontrol('parent',hf,'style','text','position',[0 FH-52 FW 18], ...
          'string','Ing. Rodrigo Bastidas  |  Marzo-Agosto 2026  |  ESPE', ...
          'fontsize',8,'foregroundcolor',[0.50 0.55 0.65], ...
          'backgroundcolor',[0.08 0.09 0.12],'horizontalalignment','center');

// --- PANEL ENTRADAS ---
uicontrol('parent',hf,'style','frame','position',[8 FH-195 334 135],'backgroundcolor',[0.11 0.12 0.16]);
uicontrol('parent',hf,'style','text','position',[16 FH-72 318 18], ...
          'string','PARAMETROS DE ENTRADA','fontsize',9,'fontweight','bold', ...
          'foregroundcolor',[0.35 0.80 0.50],'backgroundcolor',[0.11 0.12 0.16], ...
          'horizontalalignment','left');

uicontrol('parent',hf,'style','text','position',[16 FH-97 150 18], ...
          'string','Centro de Taylor (a):','fontsize',9, ...
          'foregroundcolor',[0.78 0.82 0.90],'backgroundcolor',[0.11 0.12 0.16], ...
          'horizontalalignment','left');
uicontrol('parent',hf,'style','edit','position',[172 FH-99 162 22], ...
          'string','9','fontsize',11,'fontweight','bold', ...
          'backgroundcolor',[0.22 0.24 0.30],'foregroundcolor',[1 1 1],'tag','inp_a');

uicontrol('parent',hf,'style','text','position',[16 FH-125 150 18], ...
          'string','Punto a evaluar (x):','fontsize',9, ...
          'foregroundcolor',[0.78 0.82 0.90],'backgroundcolor',[0.11 0.12 0.16], ...
          'horizontalalignment','left');
uicontrol('parent',hf,'style','edit','position',[172 FH-127 162 22], ...
          'string','10','fontsize',11,'fontweight','bold', ...
          'backgroundcolor',[0.22 0.24 0.30],'foregroundcolor',[1 1 1],'tag','inp_x');

uicontrol('parent',hf,'style','pushbutton','position',[16 FH-192 326 30], ...
          'string','  CALCULAR','fontsize',11,'fontweight','bold', ...
          'backgroundcolor',[0.12 0.58 0.38],'foregroundcolor',[1 1 1], ...
          'callback','cb_calc()');

// --- PANEL RESULTADOS ---
lbl  = ['f(x) exacto:';'P0 (1 termino):';'P1 (2 terminos):';'P2 (3 terminos):';'P3 (4 terminos):';'Error relativo %:'];
tags = ['r_ex';'r_p0';'r_p1';'r_p2';'r_p3';'r_er'];
fgc  = [[0.35 0.80 0.50];[0.72 0.74 0.82];[0.72 0.74 0.82];[0.72 0.74 0.82];[0.40 0.72 1.00];[1.00 0.78 0.25]];

for i = 1:6
    yy = FH - 215 - (i-1)*62;
    uicontrol('parent',hf,'style','frame','position',[8 yy-40 334 58],'backgroundcolor',[0.11 0.12 0.16]);
    uicontrol('parent',hf,'style','text','position',[16 yy+10 320 16], ...
              'string',lbl(i),'fontsize',8,'foregroundcolor',[0.50 0.55 0.65], ...
              'backgroundcolor',[0.11 0.12 0.16],'horizontalalignment','left');
    uicontrol('parent',hf,'style','text','position',[16 yy-32 320 30], ...
              'string','---','fontsize',12,'fontweight','bold', ...
              'foregroundcolor',fgc(i,:),'backgroundcolor',[0.11 0.12 0.16], ...
              'tag',tags(i),'horizontalalignment','left');
end

// --- PANEL TABLA PASOS ---
TX = 350; TW = FW - TX - 8;

uicontrol('parent',hf,'style','frame','position',[TX FH-430 TW 370],'backgroundcolor',[0.11 0.12 0.16]);
uicontrol('parent',hf,'style','text','position',[TX+8 FH-72 TW-16 18], ...
          'string','PROCEDIMIENTO MANUAL - WHILE (k=0,1,2,3)','fontsize',9,'fontweight','bold', ...
          'foregroundcolor',[0.35 0.80 0.50],'backgroundcolor',[0.11 0.12 0.16], ...
          'horizontalalignment','left');

// Encabezados
eh  = ['k','f(k)(a)','k!','(x-a)^k','Termino','Suma Pk'];
ex2 = [TX+4, TX+28, TX+120, TX+176, TX+248, TX+382];
ew2 = [22,   90,    54,     70,     132,    TW-234];

for j = 1:6
    uicontrol('parent',hf,'style','text','position',[ex2(j) FH-95 ew2(j) 18], ...
              'string',eh(j),'fontsize',8,'fontweight','bold', ...
              'foregroundcolor',[0.85 0.88 0.95],'backgroundcolor',[0.20 0.22 0.28], ...
              'horizontalalignment','center');
end

rbg = [[0.13 0.15 0.19];[0.10 0.12 0.15];[0.13 0.15 0.19];[0.10 0.12 0.15]];
kfg = [[0.35 0.80 0.50];[0.40 0.70 1.00];[1.00 0.78 0.25];[1.00 0.45 0.45]];

stags = ['t0k','t0d','t0f','t0h','t0t','t0s'; ...
         't1k','t1d','t1f','t1h','t1t','t1s'; ...
         't2k','t2d','t2f','t2h','t2t','t2s'; ...
         't3k','t3d','t3f','t3h','t3t','t3s'];

for r = 1:4
    ry2 = FH - 118 - (r-1)*26;
    for c = 1:6
        if c == 1 then fg2 = kfg(r,:); else fg2 = [0.78 0.82 0.90]; end
        uicontrol('parent',hf,'style','text','position',[ex2(c) ry2 ew2(c) 24], ...
                  'string','-','fontsize',8,'backgroundcolor',rbg(r,:), ...
                  'foregroundcolor',fg2,'tag',stags(r,c),'horizontalalignment','center');
    end
end

// Botón graficar separado
uicontrol('parent',hf,'style','pushbutton','position',[TX FH-445 TW 28], ...
          'string','  VER GRAFICA (ventana separada)','fontsize',10,'fontweight','bold', ...
          'backgroundcolor',[0.15 0.35 0.65],'foregroundcolor',[1 1 1], ...
          'callback','cb_grafica()');

disp('===============================================');
disp(' TAYLOR GRUPO 4  |  NRC 29528');
disp(' Presiona CALCULAR en la ventana del GUI.');
disp('===============================================');

// ============================================================
// CALLBACKS
// ============================================================

function cb_calc()
    a_v = strtod(get(findobj('tag','inp_a'),'string'));
    x_v = strtod(get(findobj('tag','inp_x'),'string'));

    if isnan(a_v) | isnan(x_v) then
        messagebox('Ingresa numeros validos.','Error','error'); return;
    end
    if (a_v+1) < 0 | (x_v+1) < 0 then
        messagebox('Necesitas x+1 >= 0 y a+1 >= 0','Error','error'); return;
    end

    [T, P] = mitaylor(a_v, x_v);
    exacto = mif(x_v);
    err    = abs((exacto - P(4)) / exacto) * 100;

    set(findobj('tag','r_ex'),'string', sprintf('%.8f', exacto));
    set(findobj('tag','r_p0'),'string', sprintf('%.8f', P(1)));
    set(findobj('tag','r_p1'),'string', sprintf('%.8f', P(2)));
    set(findobj('tag','r_p2'),'string', sprintf('%.8f', P(3)));
    set(findobj('tag','r_p3'),'string', sprintf('%.8f', P(4)));

    if err < 1 then ec = [0.30 0.85 0.40];
    elseif err < 5 then ec = [1.00 0.75 0.20];
    else ec = [1.00 0.35 0.35]; end
    set(findobj('tag','r_er'),'string',sprintf('%.6f %%',err),'foregroundcolor',ec);

    k2 = 0; r2 = 1;
    while k2 <= 3
        dk2 = mider(a_v, k2);
        fk2 = mifact(k2);
        hk2 = (x_v - a_v)^k2;
        tk2 = (dk2/fk2)*hk2;
        set(findobj('tag',stags(r2,1)),'string',string(k2));
        set(findobj('tag',stags(r2,2)),'string',sprintf('%.5f',dk2));
        set(findobj('tag',stags(r2,3)),'string',string(fk2));
        set(findobj('tag',stags(r2,4)),'string',sprintf('%.5f',hk2));
        set(findobj('tag',stags(r2,5)),'string',sprintf('%.7f',tk2));
        set(findobj('tag',stags(r2,6)),'string',sprintf('%.7f',P(r2)));
        k2 = k2+1; r2 = r2+1;
    end
endfunction

function cb_grafica()
    a_v = strtod(get(findobj('tag','inp_a'),'string'));
    x_v = strtod(get(findobj('tag','inp_x'),'string'));

    if isnan(a_v) | isnan(x_v) then
        messagebox('Primero ingresa los valores y presiona CALCULAR.','Aviso','warn'); return;
    end

    exacto = mif(x_v);
    [T, P] = mitaylor(a_v, x_v);
    err    = abs((exacto - P(4)) / exacto) * 100;

    x_min = max(-0.99, a_v - 5);
    x_max = a_v + 5;
    N     = 400;
    paso  = (x_max - x_min) / N;

    xv   = zeros(1,N+1);
    yori = zeros(1,N+1);
    yp0  = zeros(1,N+1);
    yp1  = zeros(1,N+1);
    yp2  = zeros(1,N+1);
    yp3  = zeros(1,N+1);

    for ii = 1:N+1
        xi = x_min + (ii-1)*paso;
        xv(ii) = xi;
        if (xi+1) >= 0 then
            [ti,Pi] = mitaylor(a_v, xi);
            yori(ii) = mif(xi);
            yp0(ii)  = Pi(1);
            yp1(ii)  = Pi(2);
            yp2(ii)  = Pi(3);
            yp3(ii)  = Pi(4);
        else
            yori(ii)=%nan; yp0(ii)=%nan; yp1(ii)=%nan; yp2(ii)=%nan; yp3(ii)=%nan;
        end
    end

    ylim2 = 4 * max(abs(yori(~isnan(yori))));
    for ii = 1:N+1
        if ~isnan(yp0(ii)) & abs(yp0(ii))>ylim2 then yp0(ii)=%nan; end
        if ~isnan(yp1(ii)) & abs(yp1(ii))>ylim2 then yp1(ii)=%nan; end
        if ~isnan(yp2(ii)) & abs(yp2(ii))>ylim2 then yp2(ii)=%nan; end
        if ~isnan(yp3(ii)) & abs(yp3(ii))>ylim2 then yp3(ii)=%nan; end
    end

    // Abrir ventana de gráfica separada
    scf(99);
    clf();
    plot(xv, yori, 'b-');
    plot(xv, yp0,  'color', [0.5 0.5 0.5]);
    plot(xv, yp1,  'g-');
    plot(xv, yp2,  'color', [0.85 0.65 0.0]);
    plot(xv, yp3,  'r-');
    plot(x_v, exacto, 'b+');
    plot(x_v, P(4),   'rx');
    xgrid();
    xlabel('x');
    ylabel('y');
    title(sprintf('f(x)=e^(sen(sqrt(x+1)))  |  a=%.1f  x=%.1f  |  Error P3=%.5f%%', a_v, x_v, err));
    legend(['f(x) original','P0','P1','P2','P3', ...
            sprintf('f(%.0f)=%.5f',x_v,exacto), ...
            sprintf('P3(%.0f)=%.5f',x_v,P(4))]);
endfunction
