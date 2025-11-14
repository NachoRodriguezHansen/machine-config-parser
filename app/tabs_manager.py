import streamlit as st
from files_manager import Files

class Tabs:
    def __init__(self, machine):
        self.machine = machine

    def create_tabs(self):
        tab1, tab2 = st.tabs(["  Data", "Plots"])

        with tab1:
            st.title(f"\U0001F4CB {self.machine} data")
            machine_w = Files(self.machine)
            machine_w.find_csv()
            machine_w.show_data()
            st.sidebar.write(f'Machine {self.machine}')
            machine_w.show_filtered_data()

        with tab2:
            st.title(f"\U0001F4CA {self.machine} Plots")
