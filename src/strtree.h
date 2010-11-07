//////////////////////////////////////////////////////////////////////
//
//  FILE:       strtree.h
//              String tree template class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    1.0
//
//  Notice:     Copyright (c) 1999  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

// String tree template class:
// Binary search tree for strings, with periodic rebalancing.
// Templatised for adding other data to nodes.

// A StrTree operates in two modes: Tree and List mode.

// Tree mode:
//    First and Last are unused.
//    Each Root[b] contains the binary search tree for all the nodes
//    with a string starting with the character b, or NULL if no
//    strings starting with b are in the tree.

// List mode:
//    First is the first node in the ordered linked list, and Last
//    is the last node.
//    Each Root[b] points to the first node in the linked list with
//    a string starting with the character b, or NULL if no such node
//    exists.

// The methods Lookup(), Insert(), GetFirstMatches() convert the StrTree
// to Tree mode if necessary.
// The methods AddLast(), IterateStart() and LongestPrefix() convert
// to List mode if necessary.

// When converting to Tree mode, the trees created are perfectly balanced.
// Converting between List and Tree modes takes linear time, but the
// current algorithm uses recursive function calls. The stack should
// not grow very deep, since each starting character has its own tree
// and trees are perfectly balanced when first created (by adding all the
// nodes in order with AddLast() instead of Insert()).

// Advantages of the two modes:
//   -- When adding data known to be in alphabetical order, AddLast()
//      can be used for constant-time updates. Then, when the first
//      insertion or lookup is done, the StrTree will get converted in
//      linear time to a perfectly balanced tree for each starting
//      character b.
//   -- Iterating through all the nodes of a StrTree in alphabetical order
//      is easy, by putting the StrTree in List mode first.


#ifndef SCID_STRTREE_H
#define SCID_STRTREE_H

#include <stdio.h>
#include <string.h>

#include "error.h"
#include "misc.h"


// nodeT template: a StrTree node.
template <class C>
struct nodeT {
    char  *    name;        // The string for this node.
    C          data;        // Template-specific information.
    nodeT<C> * left;
    nodeT<C> * right;
};

// There is one tree for each possible starting byte in a string:
const uint NUM_StrTrees = 256;

template <class C>
class StrTree
{
  private:

    uint  TreeSize [NUM_StrTrees];
    uint  TotalSize;
    uint  TreeHeight;
    bool  TreeMode;  // false for list layout, true for tree layout.

    bool  AllocateStrings;  // If false, caller will allocate strings.

    // Statistics:
    uint Stat_InsertsNew;
    uint Stat_InsertsFound;
    uint Stat_Lookups;
    uint Stat_LookupsFound;
    uint Stat_StrCompares;
    uint Stat_Rebalances;
    uint SearchCharCount [NUM_StrTrees]; // For statistics, a count of how
                                // many search strings start with each char.

  protected:

    nodeT<C> * Root [NUM_StrTrees];
    nodeT<C> * First;
    nodeT<C> * Last;
    nodeT<C> * Iterator;

  private:

    void MakeSubList (nodeT<C> * node);
    nodeT<C> * MakeSubTree (int size, uint depth);

  public:
#ifdef WINCE
  void* operator new(size_t sz) {
    void* m = my_Tcl_Alloc(sz);
    return m;
  }
  void operator delete(void* m) {
    my_Tcl_Free((char*)m);
  }
  void* operator new [] (size_t sz) {
    void* m = my_Tcl_AttemptAlloc(sz);
    return m;
  }

  void operator delete [] (void* m) {
    my_Tcl_Free((char*)m);
  }

#endif
    StrTree();
    ~StrTree();

    void DestroyTree (nodeT<C> * node);
    void DestroyList ();

    // SetAllocateStrings(): sets the allocation mode. A true value means
    // the StrTree explicitly allocates copies of names when inserting;
    // false means it leaves the caller to set the name pointer.
    // The mode can ONLY be changed for an empty tree!

    void  SetAllocateStrings (bool b) {
        if (TotalSize > 0) { AllocateStrings = b; }
    }
    bool  GetAllocateStrings () { return AllocateStrings; }

    uint    Size ()    { return TotalSize; }
    uint    LogSize () { return log2 (TotalSize); }
    uint    Height()   { return TreeHeight; }
    uint    FirstByteSize (byte b) { return TreeSize[b]; }

    void IterateStart() { Iterator = NULL; }
    inline nodeT<C> * Iterate ();

    void    MakeList ();
    void    MakeTree ();
    void    Rebalance () { MakeList(); MakeTree(); }

    nodeT<C> * Lookup (const char * str);
    errorT     Insert (const char * str, nodeT<C> ** returnNode);
    errorT     AddLast (const char * str, nodeT<C> ** returnNode);
    nodeT<C> * LongestPrefix  (const char * str);
    nodeT<C> * Delete (const char * str);

    void  FindMatches (const char * str, int strLen, nodeT<C> * node,
                       uint * matches, uint maxMatches, nodeT<C> ** array);
    uint  GetFirstMatches (const char * str, uint max, nodeT<C> ** results);

    void  DumpStats (FILE * fp);
    void  DumpRecurse (FILE * fp, const nodeT<C> * node, int height);
    void  DumpTree (FILE * fp);
};


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree Constructor.
//
template <class C>
StrTree<C>::StrTree()
{
    TotalSize = 0;
    TreeHeight = 0;
    First = Last = Iterator = NULL;
    TreeMode = true;

    // By default, the StrTree allocates strings itself:
    AllocateStrings = 1;

    Stat_InsertsNew = Stat_InsertsFound = Stat_Lookups = 0;
    Stat_LookupsFound = Stat_StrCompares = Stat_Rebalances = 0;

    for (uint i=0; i < NUM_StrTrees; i++) {
        TreeSize[i] = 0;
        Root[i] = NULL;
        SearchCharCount[i] = 0;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree Destructor
//
template <class C>
StrTree<C>::~StrTree()
{
    if (TreeMode) {
        for (uint i=0; i < NUM_StrTrees; i++) {
            DestroyTree (Root[i]);
        }
    } else {
        DestroyList();
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::DestroyTree(): recursively frees all nodes.
//
template <class C>
void
StrTree<C>::DestroyTree (nodeT<C> * node)
{
    if (node == NULL) { return; }
    DestroyTree (node->left);
    DestroyTree (node->right);
#ifdef WINCE
    if (AllocateStrings) { my_Tcl_Free((char*) node->name); }
    my_Tcl_Free((char*) node);
#else
    if (AllocateStrings) { delete[] node->name; }
    delete node;
#endif
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::DestroyList(): destroys the tree when in list form.
//
template <class C>
void
StrTree<C>::DestroyList ()
{
    ASSERT (TreeMode == 0);
    nodeT<C> * node = First;
    nodeT<C> * temp;
    while (node != NULL) {
        temp = node->right;
#ifdef WINCE
    if (AllocateStrings) { my_Tcl_Free((char*) node->name); }
    my_Tcl_Free((char*) node);
#else
    if (AllocateStrings) { delete[] node->name; }
    delete node;
#endif
        node = temp;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::Iterate(): used to successively grab each node in order.
//
template <class C>
inline nodeT<C> *
StrTree<C>::Iterate ()
{
    if (TreeMode) { MakeList(); }
    if (Iterator == NULL) {
        Iterator = First;
    } else {
        Iterator = Iterator->right;
    }
    return Iterator;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::MakeSubList(): recursively converts tree to list.
//
template <class C>
void
StrTree<C>::MakeSubList (nodeT<C> * node)
{
    ASSERT (node != NULL);
    if (node->left != NULL) { MakeSubList (node->left); }
    if (Last == NULL) {
        Last = First = node;
    } else {
        Last->right = node;
        Last = node;
    }
    if (node->right != NULL) { MakeSubList (node->right); }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::MakeList(): Converts the tree to list format, so that it
//      can be rebalanced with MakeTree() or iterated.
//      Pre: tree structures, with Root[i] as the root of each tree of
//           strings starting with i.
//      Post: ordered linked list, with First as the 1st node, and Last as
//            the last node. Root[i] points to the first node in the list
//            whose string starts with i.
//
template <class C>
void
StrTree<C>::MakeList () {
    if (! TreeMode) { return; }  // already have a List.
    First = Last = NULL;

    for (uint i=0; i < NUM_StrTrees; i++) {
        if (Root[i] != NULL) {
            MakeSubList (Root[i]);
        }
        Root[i] = NULL;
    }
    if (Last != NULL) {
        Last->right = NULL;
    }

    // Now set each Root[i] to be the first node starting with 'i':

    nodeT<C> * node = First;
    while (node != NULL) {
        byte b = (byte) node->name[0];
        if (Root[b] == NULL) {
            Root[b] = node;
        }
        node = node->right;
    }

    Iterator = NULL;
    TreeHeight = 0;
    TreeMode = false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::MakeSubTree(): recursively converts list to tree.
//
template <class C>
nodeT<C> *
StrTree<C>::MakeSubTree (int size, uint depth)
{
    if (size == 0) { return NULL; }
    int nLeft, nRight, mid;
    nLeft = (size - 1) / 2;
    nRight = size - nLeft - 1;
    mid = nLeft + 1;

    nodeT<C> * leftNode;
    nodeT<C> * root;

    leftNode = MakeSubTree (nLeft, depth + 1);
    ASSERT (First != NULL);
    root = First;
    First = First->right;
    root->left = leftNode;
    root->right = MakeSubTree (nRight, depth + 1);

    // Set TreeHeight if a new depth is reached:
    if (depth > TreeHeight) { TreeHeight = depth; }

    return root;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::MakeTree(): Converts from list to tree structure.
//      Pre: First is 1st node, right pointer of each node points to
//           next node in the list.
//      Post: Each Root[b] is the root of a prefectly balanced tree of
//            all the nodes with string starting with the character 'b'.
//
template <class C>
void
StrTree<C>::MakeTree ()
{
    if (TreeMode) { return; }  // already have a Tree.
    for (uint i=0; i < NUM_StrTrees; i++) {
        if (TreeSize[i] == 0) {
            Root[i] = NULL;
        } else {
            Root[i] = MakeSubTree (TreeSize[i], 1);
            // Assert that this tree has nodes that start with the
            // correct character:
            ASSERT ((byte)(Root[i]->name[0]) == i);
        }
    }
    First = Last = Iterator = NULL;
    Stat_Rebalances++;
    TreeMode = true;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::Lookup():
//      Returns a pointer to the located node, or NULL.
//
template <class C>
nodeT<C> *
StrTree<C>::Lookup (const char * str)
{
    if (! TreeMode) { MakeTree(); }
    Stat_Lookups++;
    SearchCharCount[(byte) *str]++;

    nodeT<C> * node;
    node = Root [(byte) *str];

    while (node != NULL) {
        Stat_StrCompares++;
        int result = strCompare_INLINE (str, node->name);

        if (result < 0) {
            node = node->left;
        } else if (result > 0) {
            node = node->right;
        } else {
            Stat_LookupsFound++;
            return node;
        }
    }
    return NULL;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::Insert()
//      Inserts a string. Returns OK if it was not in the tree, or
//      returns ERROR_Exists if the string is already in the tree.
//      In either case, *returnNode is set to the found or inserted node.
//
template <class C>
errorT
StrTree<C>::Insert (const char * str, nodeT<C> ** returnNode)
{
    if (! TreeMode) { MakeTree(); }

    uint treeNumber = (byte) *str;

    nodeT<C> * parent = NULL;
    nodeT<C> * node = Root [treeNumber];
    uint height = 1;
    enum {SIDE_Left, SIDE_Right} side = SIDE_Left;

    // Find the node or the place in the tree to insert it:

    while (node != NULL) {
        height++;
        Stat_StrCompares++;

        int res = strCompare_INLINE (str, node->name);
        if (res < 0) {          // Go into left subtree:
            side = SIDE_Left;
            parent = node;
            node = node->left;

        } else if (res > 0) {   // Go into right subtree:
            side = SIDE_Right;
            parent = node;
            node = node->right;

        } else {   // Match!
            Stat_InsertsFound++;
            if (returnNode != NULL) { *returnNode = node; }
            return ERROR_Exists;
        }
    }

    // If we reach here, we must add a new node:

    Stat_InsertsNew++;
#ifdef WINCE
    node = (nodeT<C> *) my_Tcl_Alloc(sizeof( nodeT<C>));
#else
    node = new nodeT<C>;
#endif
     if (AllocateStrings) {  // Allocate memory for the name string:
        node->name = strDuplicate (str);
    } else { // Leave it to the caller to set the name string:
        node->name = NULL;
    }
    node->left = node->right = NULL;
    if (parent) {
        if (side == SIDE_Left) {
            parent->left = node;
        } else {
            parent->right = node;
        }
    } else {
        Root [treeNumber] = node;
    }

    TreeSize [treeNumber]++;
    TotalSize++;

    // Set new maximum tree height:
    if (height > TreeHeight) {
        // It should only have grown by 1 at most!
        // ASSERT (height == TreeHeight + 1);
        TreeHeight = height;
    }
    if (returnNode != NULL) {
        *returnNode = node;
    }

    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::AddLast():
//      Adds a new node to the tree, assuming that it will be the
//      LAST node in alphabetical order.
//      If not already stored as a list, the tree will be converted
//      to a list before adding the node.
//      Returns: OK if successful, or ERROR_Corrupt if the name was
//      not greater alphabetically than the existing last node.
//
template <class C>
errorT
StrTree<C>::AddLast (const char * str, nodeT<C> ** returnNode)
{
    if (TreeMode) { MakeList(); }
    if (TotalSize > 0) {
        // Make sure this string is larger than the previous string added:
        // Only do this if the string starts with the same character as the
        // previous string, to avoid problems with the string comparison
        // of characters clashing with the order of the root nodes (string
        // comparison uses signed chars, but the Root[] array is of unsigned
        // chars).

        if (*str == *(Last->name)  &&
                strCompare_INLINE (str, Last->name) <= 0) {
            return ERROR_Corrupt;
        }
    }
#ifdef WINCE
    nodeT<C> * node = (nodeT<C> *) my_Tcl_Alloc(sizeof(nodeT<C>));
#else
    nodeT<C> * node = new nodeT<C>;
#endif
    if (AllocateStrings) {  // Allocate memory for the name string:
        node->name = strDuplicate (str);
    } else { // Leave it to the caller to set the name string:
        node->name = NULL;
    }
    node->right = NULL;

    if (TotalSize == 0) {
        First = Last = node;
    } else {
        Last->right = node;
        Last = node;
    }

    byte b = (byte) *str;
    if (Root[b] == NULL) {
        Root[b] = node;
    }
    TreeSize[b]++;
    TotalSize++;

    if (returnNode) { *returnNode = node; }

    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::FindMatches():
//      Finds the first 'maxMatches' matching nodes for the string 'str'
//      which has length 'strLen', and places them in the node array
//      'array'. Recursively calls itself for subtrees.
//
template <class C>
void
StrTree<C>::FindMatches (const char * str, int strLen, nodeT<C> * node,
                         uint * matches, uint maxMatches, nodeT<C> ** array)
{
    if (node == NULL) return;
    if (*matches >= maxMatches) return;

    int result = strncmp (str, node->name, strLen);
    if (result > 0) {
        // str is bigger than this node, we must move to the right:
        FindMatches (str, strLen, node->right, matches, maxMatches, array);

    } else if (result < 0) {
        // Move to the left:
        FindMatches (str, strLen, node->left, matches, maxMatches, array);

    } else { // Match!
        // First, look for more matches in the left subtree:

        FindMatches (str, strLen, node->left, matches, maxMatches, array);

        // Now, is there room for this match to be added?

        if (*matches >= maxMatches) { return; }
        array[*matches] = node;
        *matches += 1;

        // Now look for more in the right subtree, if appropriate:

        if (*matches >= maxMatches) { return; }
        FindMatches (str, strLen, node->right, matches, maxMatches, array);
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::GetFirstMatches():
//      Finds the first 'maxMatches' string matches for 'str' and
//      places them in the node array 'array'.
//      Calls FindMatches() with the appropriate Root node, which
//      recurses through that tree.
//      Returns the number of matches found, which will be in the
//      range [0 .. maxMatches].
//
template <class C>
uint
StrTree<C>::GetFirstMatches (const char * str, uint maxMatches,
                             nodeT<C> ** array)
{
    ASSERT (array != NULL  &&  maxMatches > 0);
    if (! TreeMode) { MakeTree(); }
    uint matches = 0;
    nodeT<C> * root = Root[(byte) *str];
    FindMatches (str, strlen(str), root, &matches, maxMatches, array);
    return matches;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::LongestPrefix():
//      Finds the longest string in the tree that is a prefix
//      of the input string.
//
//      Example: if the input string starts "therein ..." and
//      both "the" and "there" are in the tree, then the node
//      for "there" will be returned.
//
//      Returns NULL if no prefix string exists in the tree.
//
template <class C>
nodeT<C> *
StrTree<C>::LongestPrefix (const char * str)
{
    if (TreeMode) { MakeList(); }

    nodeT<C> * longestMatch = NULL;
    nodeT<C> * node;

    node = Root [(byte) *str];

    while (node != NULL) {
        if (node->name[0] != *str) { break; }
        if (strIsPrefix (node->name, str)) {
            longestMatch = node;
        }
        node = node->right;
    }

    return longestMatch;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::Delete():
//      Deletes the node matching the key string.
//      Returns: the node (if the key was deleted), or NULL
//      if the key was not in the tree.
//
//      The reason it returns the node that is extracted from the tree
//      instead of deleting it, is so the caller can free any memory
//      in the node's data field first. So it is the caller's
//      responsibility to actually delete the node returned.
//      The only memory this function deletes is the name, if it was
//      allocated by the StrTree at insertion (that is, if AllocateStrings
//      is true).
//
//      This function takes O(log N) time, and guarantees to keep the
//      tree height the same or decrease it -- some naive implementations
//      of deletion in a binary search tree can actually increase the
//      height.
//
template <class C>
nodeT<C> *
StrTree<C>::Delete (const char * key)
{
    ASSERT (key != NULL);

    nodeT<C> ** parentPtr;   // Address of the parent pointer.
    nodeT<C>  * toDelete;    // Node that will be deleted.
    nodeT<C>  * child;       // Node that will replace toDelete in the tree.

    if (! TreeMode) { MakeTree(); }

    // First, find the node to be deleted, and the address of the parent
    // pointer that points to it, so that can be changed:
    parentPtr = &(Root[(byte) *key]);
    toDelete = Root[(byte) *key];

    while (toDelete) {
        Stat_StrCompares++;
        int result = strCompare (key, toDelete->name);

        if (result < 0) {
            // Move into left subtree:
            parentPtr = &(toDelete->left);
            toDelete = toDelete->left;

        } else if (result > 0) {
            // Move into right subtree:
            parentPtr = &(toDelete->right);
            toDelete = toDelete->right;

        } else {  // Found the node to be deleted:
            break;
        }
    }

    if (toDelete == NULL) { return NULL; }

    // Now, we need to find a candidate child node that will move to
    // the place in the tree where toDelete is.
    // First we check simple cases: if toDelete has an empty subtree
    // pointer, the other subtree (which may/may not be empty) is the
    // child to replace toDelete.
    //
    // The next simple case is, if toDelete->right has no left subtree,
    // then toDelete->right is the candidate to replace toDelete.
    //
    // If none of these simple cases works, we find the next node after
    // toDelete in its right subtree (by going right once then left as
    // far as possible) and that node (which may be a leaf node, or may
    // have a right subtree, but obviously cannot have a left subtree)
    // is the candidate to replace toDelete.

    // First the three easy cases: see the comment above.
    if (toDelete->left == NULL) {
        child = toDelete->right;
    } else if (toDelete->right == NULL) {
        child = toDelete->left;
    } else if (toDelete->right->left == NULL) {
        child = toDelete->right;
        child->left = toDelete->left;
    } else {
        // Now the last case which involves finding the closest
        // successor of toDelete in its right subtree:

        ASSERT (toDelete->right->left);
        // searchNode is set to the parent of the successor of toDelete
        // so searchNode->left is the actual successor. This is so we
        // can snip searchNode->left (making it searchNode->left->right)
        // to remove the candidate from that part of the tree.

        nodeT<C> * searchNode;
        searchNode = toDelete->right;
        while (searchNode->left->left) { searchNode = searchNode->left; }
        ASSERT (searchNode->left);
        child = searchNode->left;
        searchNode->left = searchNode->left->right;

        // child will replace toDelete, so it needs toDelete's children as
        // its children:
        child->left = toDelete->left;
        child->right = toDelete->right;
    }

    // Finally, we can delete toDelete and set the parent pointer to
    // the child that replaces toDelete.
    // Note that child could be NULL here.

    *parentPtr = child;
    TotalSize--;
    TreeSize[(byte) *key]--;

    // We only delete toDelete->name if we allocated it, otherwise it
    // was set explicitly by the caller when it was inserted.
    if (AllocateStrings) {
#ifdef WINCE
        my_Tcl_Free(toDelete->name);
#else
        delete[] toDelete->name;
#endif
        toDelete->name = NULL;
    }

    // Finally, we return the deleted node, setting its children nodes
    // to NULL just for safety. The caller can do what it needs with
    // the node data and then delete the node itself.

    toDelete->left = toDelete->right = NULL;
    return toDelete;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::DumpTree():
//      Dumps a visual representation of the tree to an open file.
//
template <class C>
void
StrTree<C>::DumpRecurse (FILE * fp, const nodeT<C> * node, int height)
{
    if (node != NULL) {
        DumpRecurse (fp, node->right, height + 2);
        for (int i=0; i < height; i++) { putc (' ', fp); }
        fprintf (fp, "%s\n", node->name);
        DumpRecurse (fp, node->left, height + 2);
    }
}

template <class C>
void
StrTree<C>::DumpTree (FILE * fp)
{
    ASSERT (fp != NULL);
    if (! TreeMode) { MakeTree(); }
    fprintf (fp, "Height: %u\n", TreeHeight);
    for (uint i=0; i < NUM_StrTrees; i++) {
        DumpRecurse (fp, Root[i], 0);
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrTree::DumpStats():
//      Dump statistics to an open file.
//
template <class C>
void
StrTree<C>::DumpStats (FILE * fp)
{
    fprintf (fp, "Insertions: %u found, %u new, %u total\n",
             Stat_InsertsFound, Stat_InsertsNew,
             Stat_InsertsFound + Stat_InsertsNew);
    fprintf (fp, "Lookups: %u, of which %u were successfull\n",
             Stat_Lookups, Stat_LookupsFound);
    fprintf (fp, "Rebalances: %u\n", Stat_Rebalances);
    fprintf (fp, "String comparisons: %u\n", Stat_StrCompares);
    fprintf (fp, "First chars: actual / searched\n");
    for (int i=0; i < 256; i++) {
        if (TreeSize[i]  ||  SearchCharCount[i]) {
            fprintf (fp, "    %c   %7u  %7u\n", i, TreeSize[i],
                     SearchCharCount[i]);
        }
    }
}

#endif // ifndef SCID_STRTREE_H

//////////////////////////////////////////////////////////////////////
//  EOF: strtree.h
//////////////////////////////////////////////////////////////////////

