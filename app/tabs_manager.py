import streamlit as st
from files_manager import Files


class Tabs:
    def __init__(self, machine: str):
        """
        Handles creation of content tabs for a selected machine series.
        """
        self.machine = machine

        # Create Files handler once (avoids repeated processing)
        self.file_handler = Files(machine)
        self.file_handler.find_csv()
        self.file_handler.show_data()

    def create_tabs(self):
        """
        Build the UI tabs and display machine data & plots.
        """
        # Write selected machine in sidebar only once
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
