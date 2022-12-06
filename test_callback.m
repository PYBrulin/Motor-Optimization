[in, out, pid] = popen2 ("sort", "-r");
fputs (in, "these\nare\nsome\nstrings\n");
fclose (in);
EAGAIN = errno ("EAGAIN");
done = false;
do
s = fgets (out);

if (ischar (s))
    fputs (stdout, s);
    % elseif (errno ())
    % pause (0.1);
    % fclear (out);
else
    done = true;
    fprintf("Done?")
endif

until (done)
fclose (out);
waitpid (pid);
