//
//  PolisPersisting.swift
//  swift-polis
//
//  Created by Georg Tuparev on 28.03.25.
//

/// `PolisPersisting` is an API that regulate persistency and syncing for all in-memory objects having local file system representation.
public protocol PolisPersisting {

    /// `polisFileResourceFinder` should be set before any of the methods are called
    var polisFileResourceFinder: PolisFileResourceFinder! { get set }

    /// Saves all changes to the local file system
    ///
    /// The method should compare the POLIS data stored in the file system (or cached) and perform file system changes only in case both datasets differ from
    /// each other.
    /// 
    /// **Note:** if there are in-memory changes this method could change multiple files (and always at least two files).
    func saveChanges() throws

    /// Replaces the in-memory representation of a Polis item with data from the local file system
    func revertToSaved() throws

    /// Deletes the item from both - the memory cache and from the local file system
    func delete() throws

    /// Loading data from all related POLIS files
    func loadWithID(_ id: String) throws -> PolisPersisting

    /// Returns the result of the comparison between the stored POLIS item and the corresponding in-memory representation
    func didChange() -> Bool
}

/// `PersistentItem` is an abstract tat should be always subclassed by all in-memory objects
open class PersistentItem: PolisPersisting {

    public var polisFileResourceFinder: PolisFileResourceFinder!

    public func saveChanges() throws { }
    public func revertToSaved() throws { }
    public func delete() throws { }
    public func loadWithID(_ id: String) throws -> PolisPersisting { self }

    public func didChange() -> Bool { false }


}
