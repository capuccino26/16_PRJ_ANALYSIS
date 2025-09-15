# Load packages
import os
import pandas as pd
import matplotlib.pyplot as plt
from upsetplot import UpSet, from_indicators
from matplotlib_venn import venn2, venn3
from datetime import datetime

# Load data
## Net table not provided
file_path = "NET_TABLE.csv"
df = pd.read_csv(file_path, sep=";")

## Remove first column (Shared Names)
projects_16 = df.columns[1:]

# Functions
## Generate and save UpSet Plot
def generate_upset_plot(projects, filename_plot, filename_tsv, filename_log, show_percentages, output_dir):
    current_time_general = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f'Analysis for {output_dir} at {current_time_general}')
    binary_data = {}
    for project in projects:
        df[projects] = df[projects].apply(pd.to_numeric, errors="coerce")
        binary_data[project] = (df[project] > 0.8) | (df[project] < -0.8)
    
    df_binary = pd.DataFrame(binary_data)
    df_binary.index = df["shared name"]
    df_upset = from_indicators(df_binary.columns, df_binary)
    df_binary.to_csv(os.path.join(output_dir, "binary.tsv"), sep="\t", index=True)
    
    # Generate visualizations
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f'Folder created for {output_dir}')
    plt.figure(figsize=(12, 8))
    upset = UpSet(df_upset, show_percentages=show_percentages, subset_size='count', sort_by='cardinality', min_subset_size=10)
    upset.plot()
    
    # Add text with absolute values
    if not show_percentages:
        ax = plt.gca()
        for rect in ax.patches:
            height = rect.get_height()
            if height > 0:
                ax.text(rect.get_x() + rect.get_width() / 2, height + 0.5, 
                        str(int(height)), ha='center', va='bottom', fontsize=10)
    plt.savefig(os.path.join(output_dir, filename_plot), dpi=150, bbox_inches='tight')

    # Generate .tsv files with intersections
    intersections = df_upset.groupby(level=list(range(len(projects)))).size().reset_index()
    intersections.columns = list(projects) + ["count"]
    intersections.to_csv(os.path.join(output_dir, filename_tsv), sep="\t", index=True)

    # Recover shared names
    shared_names = df_binary.index.values
    intersections_with_names = intersections.copy()

    # Map shared names to intersections
    intersections_with_names['shared name'] = shared_names[:len(intersections_with_names)]
    intersections_with_names.set_index('shared name', inplace=True)
    intersections_with_names.to_csv(os.path.join(output_dir, "intersections_with_names.tsv"), sep="\t", index=True)

    # Filter for only shared intersections
    intersections_shared = intersections[intersections["count"] > 0]
    total_intersections = len(intersections_shared)
    shared_genes = {}

    # Generate general plots
    shared_indices = df_binary.index[df_binary.apply(lambda row: any(row[projects] == 1), axis=1)]
    df_binary_shared = df_binary.loc[shared_indices]

    # Generate plot with only shared genes
    plt.figure(figsize=(12, 8))
    upset_shared = UpSet(from_indicators(df_binary_shared.columns, df_binary_shared), 
                         show_percentages=show_percentages, subset_size='count', sort_by='cardinality', min_subset_size=10)
    upset_shared.plot()

    # Add number to bars
    if not show_percentages:
        ax_shared = plt.gca()
        for rect in ax_shared.patches:
            height = rect.get_height()
            if height > 0:
                ax_shared.text(rect.get_x() + rect.get_width() / 2, height + 0.5,
                               str(int(height)), ha='center', va='bottom', fontsize=10)
    shared_filename_plot = filename_plot.replace(".png", "_shared.png")
    plt.savefig(os.path.join(output_dir, shared_filename_plot), dpi=150, bbox_inches='tight')

    # Generate summary of shared intersections
    print(f'Generating LOGs for {output_dir}')
    with open(os.path.join(output_dir, filename_log), "w") as log_file:
        for _, row in intersections.iterrows():
            shared_projects = [projects[i] for i, val in enumerate(row[:-1]) if val == 1]
            
            if shared_projects:
                log_file.write(f"Intersection: {' e '.join(shared_projects)} - Shared genes: {row[-1]}\n")
            else:
                log_file.write(f"Intersection: No genes shared: {row[-1]}\n")

## Generate inividual analysis
def generate_ind_analysis(projects, filename_plot, filename_tsv, filename_log, show_percentages, output_dir):
    current_time_ind = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"Starting individual analysis for {output_dir} at {current_time_ind}")
    binary_data = {}
    for project in projects:
        binary_data[project] = (df[project] > 0.8) | (df[project] < -0.8)
    df_binary = pd.DataFrame(binary_data)
    df_binary.index = df["shared name"]
    df_upset = from_indicators(df_binary.columns, df_binary)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f'Folder created for {output_dir}')
    intersections = df_upset.groupby(level=list(range(len(projects)))).size().reset_index()
    intersections.columns = list(projects) + ["count"]

    # Filter shared intersections
    intersections_shared = intersections[intersections["count"] > 0]
    total_intersections = len(intersections_shared)
    shared_genes = {}

    # Count intersections
    start_time = datetime.now()
    for i, (_, row) in enumerate(intersections_shared.iterrows(), 1):
        shared_projects = [projects[i] for i, val in enumerate(row[:-1]) if val == 1]
        if shared_projects:
            shared_genes_set = df_binary.index[df_binary[shared_projects].all(axis=1)]
            shared_genes[', '.join(shared_projects)] = shared_genes_set.tolist()
            # Generate new .csv for each intersection
            intersection_filename = f"genes_shared_{'_'.join(shared_projects)}.csv"
            intersection_filepath = os.path.join(output_dir, intersection_filename)
            intersection_data = df[df['shared name'].isin(shared_genes_set)]
            intersection_data.to_csv(intersection_filepath, sep=";", index=False)
            # Generate VENN diagrams
            plt.figure(figsize=(8, 8))
            if len(shared_projects) == 2:
                venn_data = [len(shared_genes_set), len(shared_genes_set), len(shared_genes_set)] if not shared_genes_set.empty else [0, 0, 0]
                venn = venn2(subsets=venn_data, set_labels=(shared_projects[0], shared_projects[1]))
            elif len(shared_projects) == 3:
                venn_data = [len(shared_genes_set), len(shared_genes_set), len(shared_genes_set), len(shared_genes_set), 0, 0, 0] if not shared_genes_set.empty else [0, 0, 0, 0, 0, 0, 0]
                venn = venn3(subsets=venn_data, set_labels=(shared_projects[0], shared_projects[1], shared_projects[2]))
            plt.title(f"Venn Diagram: {' & '.join(shared_projects)}")
            venn_filename = f"venn_{'_'.join(shared_projects)}.png"
            plt.savefig(os.path.join(output_dir, venn_filename), dpi=150, bbox_inches='tight')
            plt.close()
            elapsed_time = datetime.now() - start_time
            elapsed_time_str = str(elapsed_time).split('.')[0]
            # Show progress
            print(f"Processing {output_dir} {i}/{total_intersections} - Time elapsed: {elapsed_time_str}")

    finish_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"Finished analysis for {output_dir} at {finish_time}")

# Main
generate_upset_plot(projects_16, "upset_plot_16.png", "upset_intersections_16.tsv", "upset_log_16.txt", show_percentages=True, output_dir="16_projects_analysis")
