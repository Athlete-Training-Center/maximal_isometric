function save_file(data, dir, file_name, save_exts, column_labels=~)
    save_path = sprintf("%s/%s", dir, file_name);
    % data type check
    if isa(data, "struct")
        save_data = [column_labels; struct2cell(data)];
    elseif isa(data, "cell")
        save_data = [column_labels; data{:}];
    end
    
    for ext = save_exts
        try
            split_ext = ext.split(".");
            if split_ext == "xlsx"
                writecell(save_data, sprintf('%s.%s',save_path, split_ext(end)));
            elseif split_ext == "mat"
                save(sprintf('%s.%s',save_path, split_ext(end)), "save_data");
            end
        catch exception
            disp(exception.message);
        end
    end
end