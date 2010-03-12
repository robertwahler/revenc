After('@unmount_after') do
  # unmount, no harm done if not mounted
  in_current_dir do
    `fusermount -u encrypted_destination_folder 2>&1`
  end
end
