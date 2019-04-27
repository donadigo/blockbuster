
public interface Gala.IconGroup : Clutter.Actor {
    public abstract bool active { get; set; }
    public abstract void remove_window (Meta.Window window, bool animate = true);
}

public interface Gala.WindowClone : Clutter.Actor {
    public abstract Meta.Window window { get; construct; }
}

public interface Gala.WindowCloneContainer : Clutter.Actor {

}

public interface Gala.WorkspaceClone : Clutter.Actor {
    public abstract Gala.WindowCloneContainer window_container { get; }
}