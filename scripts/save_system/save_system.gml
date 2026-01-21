// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

/// Sistema di salvataggio cross-platform per high score
/// Funziona su: Android, Windows, Steam, GX.games

// Nome del file di salvataggio
#macro SAVE_FILE "smash_squad_save.json"

/// Carica il high score dal file
/// @return {real} Il punteggio massimo salvato (0 se non esiste)
function load_high_score() {
    // Verifica se il file esiste
    if (file_exists(SAVE_FILE)) {
        try {
            // Apri il file per la lettura
            var file = file_text_open_read(SAVE_FILE);
            
            if (file != -1) {
                // Leggi il contenuto JSON
                var json_string = "";
                while (!file_text_eof(file)) {
                    json_string += file_text_read_string(file);
                    file_text_readln(file);
                }
                file_text_close(file);
                
                // Decodifica il JSON
                var data = json_parse(json_string);
                
                // Estrai il high score
                if (variable_struct_exists(data, "high_score")) {
                    var high_score_value = data.high_score; // RINOMINATO
                    return high_score_value;
                }
            }
        } catch (e) {
            show_debug_message("Errore caricamento high score: " + string(e));
        }
    }
    
    // Se il file non esiste o c'è un errore, ritorna 0
    show_debug_message("Nessun high score trovato, inizializzazione a 0");
    return 0;
}

/// Salva il high score su file
/// @param {real} score_value Il punteggio da salvare
/// @return {bool} True se il salvataggio è riuscito, false altrimenti
function save_high_score(score_value) { // RINOMINATO parametro
    try {
        // Crea la struttura dati
        var data = {
            high_score: score_value,
            last_saved: date_current_datetime()
        };
        
        // Converti in JSON
        var json_string = json_stringify(data);
        
        // Apri il file per la scrittura (sovrascrive se esiste)
        var file = file_text_open_write(SAVE_FILE);
        
        if (file != -1) {
            file_text_write_string(file, json_string);
            file_text_close(file);
            show_debug_message("High score salvato: " + string(score_value));
            return true;
        }
    } catch (e) {
        show_debug_message("Errore salvataggio high score: " + string(e));
    }
    
    return false;
}

/// Verifica se il punteggio attuale è un nuovo record
/// @param {real} current_score Il punteggio attuale
/// @param {real} high_score_value Il record attuale
/// @return {bool} True se è un nuovo record
function is_new_record(current_score, high_score_value) { // RINOMINATO parametro
    return current_score > high_score_value;
}

/// Cancella il file di salvataggio (per debug/reset)
function delete_save_file() {
    if (file_exists(SAVE_FILE)) {
        file_delete(SAVE_FILE);
        show_debug_message("File di salvataggio cancellato");
        return true;
    }
    return false;
}