// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use tauri::{CustomMenuItem, Menu, MenuItem, Submenu};

fn create_app_menu() -> Menu {
    Menu::new()
        .add_submenu(Submenu::new(
            "App",
            Menu::new()
                .add_native_item(MenuItem::Hide)
                .add_native_item(MenuItem::HideOthers)
                .add_native_item(MenuItem::ShowAll)
                .add_native_item(MenuItem::Separator)
                .add_native_item(MenuItem::Quit),

        ))
        .add_submenu(Submenu::new(
            "Project",
            Menu::new()
                .add_item(
                    CustomMenuItem::new("new-project".to_string(), "New Project")
                        .accelerator("CmdOrCtrl+N"),
                )
                .add_item(
                    CustomMenuItem::new("save_online".to_string(), "Save Online")
                )
                .add_native_item(MenuItem::Separator)
                .add_item(
                    CustomMenuItem::new("save_offline".to_string(), "Save Offline")
                        .accelerator("CmdOrCtrl+S"),
                )
                .add_item(
                    CustomMenuItem::new("open_offline".to_string(), "Open Offline")
                        .accelerator("CmdOrCtrl+O"),
                )
                .add_native_item(MenuItem::Separator)
                .add_item(
                    CustomMenuItem::new("export".to_string(), "Export as File")
                        .accelerator("CmdOrCtrl+E"),
                )
                .add_item(
                    CustomMenuItem::new("import".to_string(), "Import Project")
                        .accelerator("CmdOrCtrl+I"),
                )
                .add_native_item(MenuItem::Separator)
                .add_item(
                    CustomMenuItem::new("clear".to_string(), "Clear Project")
                )
                .add_item(
                    CustomMenuItem::new("recover".to_string(), "Recover Project")
                )
                .add_native_item(MenuItem::Separator)
                .add_item(
                    CustomMenuItem::new("preview_circuit".to_string(), "Preview Circuit")
                )
                .add_item(
                    CustomMenuItem::new("view_preview_ui".to_string(), "View Preview UI")
                )
        ))

        .add_submenu(Submenu::new(
            "Circuit",
            Menu::new()
                .add_item(
                    CustomMenuItem::new("new-circuit".to_string(), "New Circuit +")
                )
                .add_item(
                    CustomMenuItem::new("new-verilog-module".to_string(), "New Verilog Module")
                )
                .add_item(
                    CustomMenuItem::new("insert-sub-circuit".to_string(), "Insert SubCircuit")
                )
        ))

        .add_submenu(Submenu::new(
            "Tools",
            Menu::new()
                .add_item(
                    CustomMenuItem::new("combinational_analysis".to_string(), "Combinational Analysis")
                )
                .add_item(
                    CustomMenuItem::new("hex-bin-dec".to_string(), "Hex-Bin-Dec Converter")
                )
                .add_item(
                    CustomMenuItem::new("download-image".to_string(), "Download Image")
                )
                .add_item(
                    CustomMenuItem::new("themes".to_string(), "Themes")
                )
                .add_item(
                    CustomMenuItem::new("custom-shortcut".to_string(), "Custom Shortcut")
                )
                .add_item(
                    CustomMenuItem::new("export-verilog".to_string(), "Export Verilog")
                )
        ))

        .add_submenu(Submenu::new(
            "Edit",
            Menu::new()
                .add_native_item(MenuItem::Undo)
                .add_native_item(MenuItem::Redo)
                .add_native_item(MenuItem::Separator)
                .add_native_item(MenuItem::Cut)
                .add_native_item(MenuItem::Copy)
                .add_native_item(MenuItem::Paste)
                .add_native_item(MenuItem::Separator)
                .add_native_item(MenuItem::SelectAll)
        ))

        .add_submenu(Submenu::new(
            "Help",
            Menu::new()
                .add_item(
                    CustomMenuItem::new("tutorial".to_string(), "Tutorial Guide")
                )
                .add_item(
                    CustomMenuItem::new("user-manual".to_string(), "User Manual")
                )
                .add_item(
                    CustomMenuItem::new("learn-digital-logic".to_string(), "Learn Digital Logic")
                )
                .add_item(
                    CustomMenuItem::new("discussion-forum".to_string(), "Discussion Forum")
                )
        ))
}

fn main() {
  tauri::Builder::default()
    .menu(create_app_menu())
    .on_menu_event(|event| {
      match event.menu_item_id() {
        "new-project" => {
          event.window().emit("new-project", {}).unwrap();
        }
        "save_online" => {
          event.window().emit("save_online", {}).unwrap();
        }
        "save_offline" => {
          event.window().emit("save_offline", {}).unwrap();
        }
        "open_offline" => {
          event.window().emit("open_offline", {}).unwrap();
        }
        "export" => {
          event.window().emit("export", {}).unwrap();
        }
        "import" => {
          event.window().emit("import", {}).unwrap();
        }
        "clear" => {
          event.window().emit("clear", {}).unwrap();
        }
        "recover" => {
          event.window().emit("recover", {}).unwrap();
        }
        "preview_circuit" => {
          event.window().emit("preview_circuit", {}).unwrap();
        }
        "view_preview_ui" => {
          event.window().emit("view_preview_ui", {}).unwrap();
        }
        "new-circuit" => {
          event.window().emit("new-circuit", {}).unwrap();
        }
        "new-verilog-module" => {
          event.window().emit("new-verilog-module", {}).unwrap();
        }
        "insert-sub-circuit" => {
          event.window().emit("insert-sub-circuit", {}).unwrap();
        }
        "combinational_analysis" => {
          event.window().emit("combinational_analysis", {}).unwrap();
        }
        "hex-bin-dec" => {
          event.window().emit("hex-bin-dec", {}).unwrap();
        }
        "download-image" => {
          event.window().emit("download-image", {}).unwrap();
        }
        "themes" => {
          event.window().emit("themes", {}).unwrap();
        }
        "custom-shortcut" => {
          event.window().emit("custom-shortcut", {}).unwrap();
        }
        "export-verilog" => {
          event.window().emit("export-verilog", {}).unwrap();
        }
        "tutorial" => {
          event.window().emit("tutorial", {}).unwrap();
        }
        "user-manual" => {
          event.window().emit("user-manual", {}).unwrap();
        }
        "learn-digital-logic" => {
          event.window().emit("learn-digital-logic", {}).unwrap();
        }
        "discussion-forum" => {
          event.window().emit("discussion-forum", {}).unwrap();
        }
        _ => {}
      }
    })
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}
