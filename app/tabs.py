import streamlit as st
from files_manager import Files


class Data:
    def __init__(self, machine: str):
        self.machine = machine
        self.file_handler = Files(machine)
        self.file_handler.find_csv()
        self.file_handler.show_data()

    def create_tabs(self):
        st.sidebar.write(f"Machine: {self.machine}")

        tab_data, tab_plots = st.tabs(["  Data", "Plots"])

        with tab_data:
            st.title(f"\U0001F4CB {self.machine} Data")

            if self.file_handler.correct_file is None:
                st.warning(f"No CSV available for machine '{self.machine}'")
                return

            # Show filtered DataFrame
            self.file_handler.show_filtered_data()

        with tab_plots:
            st.title(f"\U0001F4CA {self.machine} Plots")

            # Placeholder for future functionality
            st.info("Plotting features will be added here soon.")


class Plots:
    def __init__(self, machine: str):
        self.machine = machine