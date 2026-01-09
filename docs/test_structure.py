#!/usr/bin/env python3

import os
import re

def test_markdown_structure():
    """Test that all required Markdown files exist and have proper structure"""
    
    base_dir = os.path.dirname(os.path.abspath(__file__))
    sections_dir = os.path.join(base_dir, "_sections")
    
    # Required section files
    required_sections = [
        "features.md",
        "installation.md",
        "usage.md",
        "requirements.md",
        "faq.md",
        "support.md",
        "changelog.md",
        "license.md"
    ]
    
    print("Testing Markdown content structure...\n")
    
    # Test 1: Check if all section files exist
    print("✓ Checking section files...")
    for section in required_sections:
        file_path = os.path.join(sections_dir, section)
        if os.path.exists(file_path):
            print(f"  ✓ {section} exists")
        else:
            print(f"  ✗ {section} is missing!")
            return False
    
    # Test 2: Check if index.md exists
    print("\n✓ Checking main index file...")
    index_path = os.path.join(base_dir, "index.md")
    if os.path.exists(index_path):
        print(f"  ✓ index.md exists")
    else:
        print(f"  ✗ index.md is missing!")
        return False
    
    # Test 3: Verify index.md includes all sections
    print("\n✓ Verifying index.md includes all sections...")
    with open(index_path, 'r', encoding='utf-8') as f:
        index_content = f.read()
    
    for section in required_sections:
        include_pattern = f"{{% include_relative _sections/{section} %}}"
        if include_pattern in index_content:
            print(f"  ✓ Includes {section}")
        else:
            print(f"  ✗ Missing include for {section}")
            return False
    
    # Test 4: Check that section files have content
    print("\n✓ Checking section file content...")
    for section in required_sections:
        file_path = os.path.join(sections_dir, section)
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if len(content) > 100:  # Should have at least some content
            print(f"  ✓ {section} has content ({len(content)} characters)")
        else:
            print(f"  ✗ {section} appears to be empty or too short")
            return False
    
    # Test 5: Verify Markdown headers in sections
    print("\n✓ Checking Markdown headers...")
    for section in required_sections:
        file_path = os.path.join(sections_dir, section)
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check for at least one heading
        if re.search(r'^#+\s+.+', content, re.MULTILINE):
            print(f"  ✓ {section} has proper headers")
        else:
            print(f"  ✗ {section} missing headers")
            return False
    
    print("\n" + "="*50)
    print("✓ All tests passed! Content structure is correct.")
    print("="*50)
    return True

if __name__ == "__main__":
    success = test_markdown_structure()
    exit(0 if success else 1)
