
function descriptor()
    return { title = "Last Played Manager" ;
    version = "1.0" ;
    author = "Neetesh Kumar" ;
    capabilities = {"input-listener","meta-listener"} }
end

function activate()
    location = vlc.config.homedir().."\\VLC Tv Manager\\"
    
    main_dialog()


end

function main_dialog()
    dlg = vlc.dialog("TV Show Playlist")
    list = dlg:add_list(1, 3, 4, 1)
    button_play = dlg:add_button("Play", click_play, 1, 4, 2, 1)
    but = dlg:add_button("Delete", delete_show, 3, 4, 2, 1)
    create = dlg:add_button("Create", create_pl_dia,1,5,4,1)
    -- Add the radio stations
    local f = io.open(location.."show.txt","r")
    if f~=nil then
        local idx = 1;
        while true do
            l = f:read()
            if l==nil then break end
            list:add_value(l,idx)
            idx = idx+1
        end
    end
    f:close()
    dlg:show()
end
function create_pl_dia()
    dlg:delete()
    cre = vlc.dialog("Create Playlist")

    w = cre:add_label( "Load All The Files in the Playlist & Enter The Name Of the Show",1, 3, 1, 1)
    w = cre:add_label( "",1, 4, 4, 1)
    playlist_name = cre:add_text_input("",1, 5, 4, 1)
    create_play = cre:add_button("Create Playlist", create_pl,1,6,4, 1)
    go_dialog = cre:add_button("Go To Main", go_main_dialog,1,7,4, 1)
    msg = cre:add_label( "",1, 8, 4, 1)

end

function create_pl()
    vlc.msg.info("Creating Playlist")
    show_name = playlist_name:get_text()


    vlc.msg.info(playlist_name:get_text())
    vlc.msg.info(vlc.config.homedir())
    io.output(location .. show_name.." Files.txt")
    for i, item in pairs(vlc.playlist.get("playlist",false).children) do
        vlc.msg.info("\n",item.path)
        vlc.msg.info("\n",item.name)
        io.write(item.path.."\n")
        io.write(item.name.."\n")
    end

    io.close()

    local f = io.open(location.."show.txt","a")
    if f==nil then
         io.output(location.."show.txt")
         f = io.open(location.."show.txt","a")
    end
    f:write(show_name.."\n")
    f:close()
    msg:set_text("Created Successfully")

end

function go_main_dialog()
    cre:delete()
    main_dialog()
end

function meta_changed()
    change_detected()

end

function input_changed()

    filepath = vlc.playlist.get( vlc.playlist.current()).path
    filename = vlc.playlist.get( vlc.playlist.current()).name

end

function change_detected()
    local time = vlc.var.get(vlc.object.input(), "time")


    if(filename==nil)then  vlc.msg.info(filename.."--->"..time) 
        io.output(location .. show_name.."_Last_Played.txt")
        io.write(filename.."\n")
        io.write(filepath.."\n")
        io.write(time.."\n")
        io.close()

    end
    if(filename~=nil)then 
        if(time~=0)then
    --Saved The Time And Video In File
    vlc.msg.info(show_name.."--->"..  filename.."--->"..time) 
    io.output(location .. show_name.."_Last_Played.txt")
    io.write(filename.."\n")
    io.write(filepath.."\n")
    io.write(time.."\n")
    io.close()

end

end


end
function delete_show()
    local selec = list:get_selection()

    if (not selec) then return 1 end
    local sel = nil
    for idx, selectedItem in pairs(selec) do

        sel = selectedItem
        break
    end
    vlc.msg.info(sel)
    local f = io.open(location.."show.txt","r")
    if(f~=nil)then 
        local f_s = {}
        local idx = 1
         while true do
            local l = f:read()
            if l==nil then break end
            if(l ~= sel) then
                f_s[idx] = l
                idx = idx+1
            end
             
        end
        f:close()
         io.output(location.."show.txt")
        for k,v in pairs(f_s) do
            
            io.write(v.."\n")
        end
        io.close()
        list:clear()
    f = io.open(location.."show.txt","r")
    if f~=nil then
        local idx = 1;
        while true do
            l = f:read()
            if l==nil then break end
            list:add_value(l,idx)
            idx = idx+1
        end
    end
    f:close()
    os.remove(location .. sel.."_Last_Played.txt")
    os.remove(location .. sel.." Files.txt")
    

    end
end
function click_play()

    filepath = ""
    filename = ""
    selection = list:get_selection()

    if (not selection) then return 1 end
    local sel = nil
    for idx, selectedItem in pairs(selection) do

        sel = selectedItem
        break
    end
    show_name = sel
    vlc.msg.info(os.date (format, time))
    pl_table = {}
    local fn =""
    local fp =""
    local ft =""
    local id = ""
    local f = assert(io.open(location..sel.." Files.txt","r"))
    local  fr = io.open(location .. show_name.."_Last_Played.txt")
    if fr ~=nil then 
        fn = fr:read()
        fp = fr:read()
        ft = fr:read()
    end

    local idx = 1;
    while true do
        local path = f:read()
        local name = f:read()
        if path==nil then break end
        pl_table[idx] = {}
        pl_table[idx].path = path 
        pl_table[idx].name =  name
        pl_table[idx].title = name
        if(ft~=nil and pl_table[idx].path  == fp ) then
            pl_table[idx].options = {"start-time=" .. ft}
        end

        idx = idx+1
    end
    f:close()

    vlc.playlist.clear()
    vlc.playlist.enqueue(pl_table)


    if(fr==nil)then

        vlc.msg.info("Error") 

        vlc.playlist.play()
    else



        for i, item in pairs(vlc.playlist.get("playlist",false).children) do
            if (item.path == fp) then
                id = item.id


            end

        end



        vlc.playlist.gotoitem( id ) 
        vlc.msg.info(id)
        vlc.playlist.play()
    end
    fr:close()
    dlg:hide()



end

function deactivate()

end

function close()

end
