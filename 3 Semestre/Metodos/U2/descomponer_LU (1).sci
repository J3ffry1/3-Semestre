// =========================================================
// PROGRAMA: METODO DE DESCOMPOSICION LU (INTEGRAL)
// GRUPO 4 - METODOS NUMERICOS
// Resuelve Ax = b mediante A = L * U (Doolittle)
// TODOS LOS BUCLES USAN EXCLUSIVAMENTE 'while'
// =========================================================

global n_size;
global A_entries;
global b_entries;
global steps_text;
global sol_text;
global fig_main;
global size_edit_global;

n_size = 0;
A_entries = list();
b_entries = list();
fig_main = [];

// =========================================================
// METODO DE DESCOMPOSICION LU CON SUSTITUCIONES
// =========================================================
function [x, L, U, steps, error_max] = metodo_lu_completo(A, b)
    n = size(A, 1);
    steps = [];
    tic();

    steps($+1) = '========================================';
    steps($+1) = '       GRUPO 4 - FACTORIZACION LU       ';
    steps($+1) = '========================================';
    steps($+1) = '';
    
    L = zeros(n, n);
    U = zeros(n, n);
    
    i = 1;
    while i <= n
        L(i, i) = 1;
        i = i + 1;
    end

    steps($+1) = '>> PASO 1: CALCULO DE MATRICES L Y U:';
    steps($+1) = '----------------------------------------';

    i = 1;
    while i <= n
        j = i;
        while j <= n
            suma = 0;
            k = 1;
            while k <= i - 1
                suma = suma + L(i, k) * U(k, j);
                k = k + 1;
            end
            U(i, j) = A(i, j) - suma;
            j = j + 1;
        end
        steps($+1) = sprintf(' * Fila %d de U -> Calculada.', i);

        if abs(U(i, i)) < 1e-12 then
            steps($+1) = 'ERROR: Pivote nulo en la diagonal de U.';
            error('Pivote nulo en U - Deteniendo operacion');
        end

        j = i + 1;
        while j <= n
            suma = 0;
            k = 1;
            while k <= i - 1
                suma = suma + L(j, k) * U(k, i);
                k = k + 1;
            end
            L(j, i) = (A(j, i) - suma) / U(i, i);
            j = j + 1;
        end
        steps($+1) = sprintf(' * Columna %d de L -> Calculada.', i);
        i = i + 1;
    end
    steps($+1) = '';

    // PASO 2: Sustitucion Progresiva L * y = b
    steps($+1) = '>> PASO 2: SUSTITUCION PROGRESIVA (L * y = b):';
    steps($+1) = '----------------------------------------';
    y = zeros(n, 1);
    i = 1;
    while i <= n
        suma = 0;
        k = 1;
        while k <= i - 1
            suma = suma + L(i, k) * y(k);
            k = k + 1;
        end
        y(i) = b(i) - suma;
        steps($+1) = sprintf('   y[%d] = %.4f', i, y(i));
        i = i + 1;
    end
    steps($+1) = '';

    // PASO 3: Sustitucion Regresiva U * x = y
    steps($+1) = '>> PASO 3: SUSTITUCION REGRESIVA (U * x = y):';
    steps($+1) = '----------------------------------------';
    x = zeros(n, 1);
    i = n;
    while i >= 1
        suma = 0;
        k = i + 1;
        while k <= n
            suma = suma + U(i, k) * x(k);
            k = k + 1;
        end
        x(i) = (y(i) - suma) / U(i, i);
        steps($+1) = sprintf('   x[%d] = %.4f', i, x(i));
        i = i - 1;
    end
    
    t = toc();
    steps($+1) = '';
    steps($+1) = sprintf('Tiempo de ejecucion: %.5f s', t);

    residuo = A*x - b;
    error_max = max(abs(residuo));
    steps($+1) = sprintf('Error maximo absoluto: %.2e', error_max);
endfunction

// =========================================================
// CREAR CAMPOS DINAMICOS EN LA INTERFAZ (A y b JUNTOS)
// =========================================================
function crear_sistema_func()
    global n_size;
    global A_entries;
    global b_entries;
    global fig_main;
    global size_edit_global;
    global steps_text;
    global sol_text;

    n_str = get(size_edit_global, 'string');
    n = evstr(n_str);

    if n < 1 | n > 10 then
        messagebox('El tamano debe estar entre 1 y 10', 'Error', 'error');
        return;
    end

    if A_entries <> [] then
        i = 1;
        while i <= size(A_entries)
            if A_entries(i) <> [] then
                j = 1;
                while j <= size(A_entries(i))
                    delete(A_entries(i)(j));
                    j = j + 1;
                end
            end
            i = i + 1;
        end
    end
    if b_entries <> [] then
        i = 1;
        while i <= size(b_entries)
            delete(b_entries(i));
            i = i + 1;
        end
    end

    A_entries = list();
    b_entries = list();
    ancho = 52;
    x0 = 35;

    uicontrol(fig_main, 'style', 'text', ...
              'string', 'MATRIZ DE COEFICIENTES (A)', ...
              'position', [x0, 500, 220, 20], ...
              'fontsize', 10, 'fontweight', 'bold', ...
              'backgroundcolor', [0.15 0.18 0.22], ...
              'foregroundcolor', [0.4 0.8 0.6]);
              
    y_pos = 465;
    i = 1;
    while i <= n
        fila = list();
        x_pos = x0;
        j = 1;
        while j <= n
            edit = uicontrol(fig_main, 'style', 'edit', ...
                             'string', '0', ...
                             'position', [x_pos, y_pos, ancho-2, 23], ...
                             'fontsize', 10, ...
                             'backgroundcolor', [0.95 0.95 0.98]);
            fila($+1) = edit;
            x_pos = x_pos + ancho;
            j = j + 1;
        end
        A_entries($+1) = fila;
        y_pos = y_pos - 27;
        i = i + 1;
    end

    x_vec = x0 + n * ancho + 25;
    uicontrol(fig_main, 'style', 'text', ...
              'string', 'VEC (b)', ...
              'position', [x_vec, 500, 55, 20], ...
              'fontsize', 10, 'fontweight', 'bold', ...
              'backgroundcolor', [0.15 0.18 0.22], ...
              'foregroundcolor', [0.4 0.8 0.6]);
              
    y_pos = 465;
    i = 1;
    while i <= n
        edit = uicontrol(fig_main, 'style', 'edit', ...
                         'string', '0', ...
                         'position', [x_vec, y_pos, 55, 23], ...
                         'fontsize', 10, ...
                         'backgroundcolor', [0.95 0.95 0.98]);
        b_entries($+1) = edit;
        y_pos = y_pos - 27;
        i = i + 1;
    end

    n_size = n;
    set(steps_text, 'string', [sprintf('Malla de %dx%d estructurada.', n, n); 'Escriba coeficientes + resultados b, luego presione CALCULAR']);
    set(sol_text, 'string', ['ESTADO: Esperando ejecucion.']);
endfunction

// =========================================================
// CARGAR VALORES DE UN EJEMPLO
// =========================================================
function cargar_ejemplo_func()
    global n_size;
    global A_entries;
    global b_entries;
    global size_edit_global;
    global steps_text;

    set(size_edit_global, 'string', '3');
    crear_sistema_func();

    A_ej = [2, 3, -1; 4, 4, -3; 2, -3, 1];
    b_ej = [5; 3; -1];

    i = 1;
    while i <= 3
        j = 1;
        while j <= 3
            set(A_entries(i)(j), 'string', string(A_ej(i, j)));
            j = j + 1;
        end
        set(b_entries(i), 'string', string(b_ej(i)));
        i = i + 1;
    end

    set(steps_text, 'string', ['Ejemplo academico cargado en las celdas.']);
endfunction

// =========================================================
// ACCION DEL BOTON PRINCIPAL CALCULAR
// =========================================================
function resolver_sistema_func()
    global n_size;
    global A_entries;
    global b_entries;
    global steps_text;
    global sol_text;

    if n_size == 0 then return; end

    n = n_size;
    A = zeros(n, n);
    b = zeros(n, 1);

    i = 1;
    while i <= n
        j = 1;
        while j <= n
            A(i, j) = evstr(get(A_entries(i)(j), 'string'));
            j = j + 1;
        end
        b(i) = evstr(get(b_entries(i), 'string'));
        i = i + 1;
    end

    [x, L, U, pasos, error_max] = metodo_lu_completo(A, b);
    set(steps_text, 'string', pasos);

    sol = [];
    sol($+1) = '=== COMPILACION DE RESPUESTAS FINALES ===';
    sol($+1) = '';
    
    sol($+1) = '>> VALORES HALLADOS PARA EL VECTOR VARIABLE X:';
    i = 1;
    while i <= n
        sol($+1) = sprintf('   -> Incognita x[%d] = %14.6f', i, x(i));
        i = i + 1;
    end
    sol($+1) = '';
    sol($+1) = sprintf(' Precision Residual Global: %.2e', error_max);
    sol($+1) = '------------------------------------------';
    sol($+1) = ' ESTRUCTURA INTERNA DE LAS MATRICES COMPONENTES:';
    sol($+1) = '------------------------------------------';
    
    sol($+1) = 'Matriz Inferior L (Doolittle):';
    i = 1;
    while i <= n
        fila = '   [ ';
        j = 1;
        while j <= n
            fila = fila + sprintf('%8.3f ', L(i, j));
            j = j + 1;
        end
        sol($+1) = fila + ']';
        i = i + 1;
    end
    sol($+1) = '';
    
    sol($+1) = 'Matriz Superior U:';
    i = 1;
    while i <= n
        fila = '   [ ';
        j = 1;
        while j <= n
            fila = fila + sprintf('%8.3f ', U(i, j));
            j = j + 1;
        end
        sol($+1) = fila + ']';
        i = i + 1;
    end

    set(sol_text, 'string', sol);
endfunction

// =========================================================
// REINICIAR TODO
// =========================================================
function limpiar_todo_func()
    global n_size;
    global A_entries;
    global b_entries;
    global steps_text;
    global sol_text;
    
    if n_size > 0 then
        i = 1;
        while i <= n_size
            j = 1;
            while j <= size(A_entries(i))
                set(A_entries(i)(j), 'string', '0');
                j = j + 1;
            end
            set(b_entries(i), 'string', '0');
            i = i + 1;
        end
    end
    set(steps_text, 'string', ['Limpieza ejecutada.']);
    set(sol_text, 'string', ['Celdas listas en cero.']);
endfunction

// =========================================================
// INTERFAZ GRAFICA COMPLETA - MODO OSCURO "DARK MATRIX"
// =========================================================
function main_gui()
    global fig_main;
    global size_edit_global;
    global steps_text;
    global sol_text;

    clc;
    c_fondo = [0.11 0.13 0.16];       
    c_banner = [0.07 0.31 0.23];      
    c_panel = [0.15 0.18 0.22];       
    c_letras = [0.90 0.93 0.96];      
    
    c_btn_crear = [0.08 0.45 0.35];   
    c_btn_ejemplo = [0.25 0.35 0.45]; 
    c_btn_solve = [0.75 0.48 0.05];   
    c_btn_clear = [0.55 0.15 0.15];   

    fig_main = figure('figure_name', 'MÉTODOS NUMÉRICOS - COMPILADOR LU [GRUPO 4]', ...
                      'position', [50, 50, 1140, 720], ...
                      'backgroundcolor', c_fondo, ...
                      'resize', 'off');

    uicontrol(fig_main, 'style', 'text', ...
              'string', 'COMPILADOR DE DESCOMPOSICIÓN MATRICIAL LU  |  GRUPO 4', ...
              'position', [0, 665, 1140, 35], ...
              'fontsize', 12, 'fontweight', 'bold', ...
              'backgroundcolor', c_banner, ...
              'foregroundcolor', [1 1 1]);

    // Contenedor principal de datos (A y b)
    uicontrol(fig_main, 'style', 'frame', ...
              'position', [20, 140, 530, 505], ...
              'backgroundcolor', c_panel, ...
              'foregroundcolor', [0.3 0.4 0.5]);

    uicontrol(fig_main, 'style', 'text', ...
              'string', 'DIMENSIÓN DEL SISTEMA (N):', ...
              'position', [40, 610, 200, 20], ...
              'fontsize', 10, 'fontweight', 'bold', ...
              'backgroundcolor', c_panel, ...
              'foregroundcolor', c_letras);

    size_edit = uicontrol(fig_main, 'style', 'edit', ...
                          'string', '3', ...
                          'position', [245, 610, 45, 22], ...
                          'fontsize', 10, ...
                          'backgroundcolor', [1 1 1]);
    size_edit_global = size_edit;

    create_btn = uicontrol(fig_main, 'style', 'pushbutton', ...
                           'string', 'GENERAR MALLA', ...
                           'position', [310, 607, 110, 26], ...
                           'fontsize', 9, 'fontweight', 'bold', ...
                           'backgroundcolor', c_btn_crear, ...
                           'foregroundcolor', [1 1 1]);

    example_btn = uicontrol(fig_main, 'style', 'pushbutton', ...
                            'string', 'VOLCAR EJEMPLO', ...
                            'position', [430, 607, 100, 26], ...
                            'fontsize', 9, 'fontweight', 'bold', ...
                            'backgroundcolor', c_btn_ejemplo, ...
                            'foregroundcolor', [1 1 1]);

    // Paneles derechos para consola de traza y soluciones
    uicontrol(fig_main, 'style', 'text', ...
              'string', 'TRAZA DE CONTROL ITERATIVO DE OPERACIONES (WHILE):', ...
              'position', [570, 615, 420, 20], ...
              'fontsize', 10, 'fontweight', 'bold', ...
              'backgroundcolor', c_fondo, ...
              'foregroundcolor', [0.4 0.8 0.6]);

    steps_text = uicontrol(fig_main, 'style', 'listbox', ...
                           'string', ['Consola de Analisis LU Activa'], ...
                           'position', [570, 350, 545, 260], ...
                           'fontsize', 9, ...
                           'fontname', 'Courier New', ...
                           'backgroundcolor', [0.08 0.09 0.11], ...
                           'foregroundcolor', [0.4 0.9 0.5]);

    uicontrol(fig_main, 'style', 'text', ...
              'string', 'SOLUCIONES FINALES DEL SISTEMA Y COMPONENTES MATRICIALES:', ...
              'position', [570, 315, 480, 20], ...
              'fontsize', 10, 'fontweight', 'bold', ...
              'backgroundcolor', c_fondo, ...
              'foregroundcolor', [0.4 0.8 0.6]);

    sol_text = uicontrol(fig_main, 'style', 'listbox', ...
                         'string', ['Esperando comando de ejecucion...'], ...
                         'position', [570, 45, 545, 265], ...
                         'fontsize', 9, ...
                         'fontname', 'Courier New', ...
                         'backgroundcolor', [0.08 0.09 0.11], ...
                         'foregroundcolor', [0.9 0.9 0.9]);

    // Botonera de control inferior
    solve_btn = uicontrol(fig_main, 'style', 'pushbutton', ...
                          'string', 'CALCULAR SISTEMA (LU)', ...
                          'position', [20, 60, 250, 45], ...
                          'fontsize', 11, 'fontweight', 'bold', ...
                          'backgroundcolor', c_btn_solve, ...
                          'foregroundcolor', [1 1 1]);

    clear_btn = uicontrol(fig_main, 'style', 'pushbutton', ...
                          'string', 'RESETEAR', ...
                          'position', [280, 60, 130, 45], ...
                          'fontsize', 10, 'fontweight', 'bold', ...
                          'backgroundcolor', c_btn_clear, ...
                          'foregroundcolor', [1 1 1]);

    exit_btn = uicontrol(fig_main, 'style', 'pushbutton', ...
                         'string', 'CERRAR', ...
                         'position', [420, 60, 130, 45], ...
                         'fontsize', 10, 'fontweight', 'bold', ...
                         'backgroundcolor', [0.25 0.25 0.25], ...
                         'foregroundcolor', [1 1 1]);

    set(create_btn, 'callback', 'crear_sistema_func');
    set(solve_btn, 'callback', 'resolver_sistema_func');
    set(example_btn, 'callback', 'cargar_ejemplo_func');
    set(clear_btn, 'callback', 'limpiar_todo_func');
    set(exit_btn, 'callback', 'close(fig_main)');

    crear_sistema_func();
endfunction

main_gui();
